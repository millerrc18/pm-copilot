# frozen_string_literal: true

require "digest"

class OpsImportService
  Result = Struct.new(:ok, :import, :errors, keyword_init: true)

  REPORT_CONFIG = {
    "materials" => {
      required: %w[part_number supplier receipt_date quantity_received unit_cost extended_cost],
      model: OpsMaterial
    },
    "shop_orders" => {
      required: %w[order_number status due_date order_quantity],
      model: OpsShopOrder
    },
    "shop_order_operations" => {
      required: %w[order_number operation_number status],
      model: OpsShopOrderOperation
    },
    "historical_efficiency" => {
      required: %w[period_start planned_hours actual_hours],
      model: OpsHistoricalEfficiency
    },
    "scrap" => {
      required: %w[scrap_date part_number scrap_quantity scrap_cost],
      model: OpsScrapRecord
    },
    "mrb_part_details" => {
      required: %w[mrb_number status part_number quantity unit_cost],
      model: OpsMrbPartDetail
    },
    "mrb_dispo_lines" => {
      required: %w[mrb_number disposition disposition_quantity],
      model: OpsMrbDispoLine
    },
    "bom" => {
      required: %w[parent_part_number component_part_number quantity_per level],
      model: OpsBomComponent
    }
  }.freeze

  TEMPLATE_HEADERS = {
    "materials" => %w[
      part_number part_description supplier commodity buyer purchase_order order_date need_date receipt_date
      quantity_ordered quantity_received unit_cost extended_cost lead_time_days
    ],
    "shop_orders" => %w[
      order_number release_number status part_number part_description work_center planned_start planned_finish
      actual_start actual_finish due_date order_quantity completed_quantity remaining_quantity estimated_hours actual_hours
    ],
    "shop_order_operations" => %w[
      order_number operation_number sequence status work_center scheduled_start scheduled_finish actual_start actual_finish
      setup_hours run_hours labor_hours queue_time
    ],
    "historical_efficiency" => %w[
      period_start period_end labor_category work_center planned_hours actual_hours variance_hours efficiency_percent
    ],
    "scrap" => %w[
      scrap_date part_number part_description reason_code shop_order_number scrap_quantity scrap_cost
    ],
    "mrb_part_details" => %w[
      mrb_number line_number status disposition part_number part_description supplier created_date closed_date
      quantity unit_cost extended_cost
    ],
    "mrb_dispo_lines" => %w[
      mrb_number line_number disposition responsible disposition_date disposition_quantity disposition_cost
    ],
    "bom" => %w[
      parent_part_number component_part_number component_description unit level quantity_per effective_from effective_to
    ]
  }.freeze

  def initialize(user:, program:, report_type:, file:)
    @user = user
    @program = program
    @report_type = report_type
    @file = file
  end

  def call
    unless OpsImport::REPORT_TYPES.include?(@report_type)
      return Result.new(ok: false, import: nil, errors: [ "Unknown report type." ])
    end

    checksum = Digest::SHA256.file(@file.tempfile.path).hexdigest
    if OpsImport.exists?(program: @program, report_type: @report_type, checksum: checksum)
      return Result.new(ok: false, import: nil, errors: [ "This file has already been imported for this program." ])
    end

    sheet = load_sheet
    return Result.new(ok: false, import: nil, errors: [ "Unable to read the spreadsheet." ]) unless sheet

    header_map = header_index_map(sheet)
    missing = required_headers.reject { |key| header_map.key?(key) }
    if missing.any?
      return Result.new(ok: false, import: nil, errors: [ "Missing required column(s): #{missing.join(', ')}" ])
    end

    errors = []
    rows_imported = 0
    rows_rejected = 0
    import = nil

    ActiveRecord::Base.transaction do
      import = OpsImport.create!(
        program: @program,
        imported_by: @user,
        report_type: @report_type,
        source_filename: @file.original_filename,
        checksum: checksum,
        status: "processing",
        imported_at: Time.current
      )

      each_sheet_row(sheet) do |row_number, values|
        next if blank_row?(values)

        attrs, row_error = build_attrs(values, header_map, row_number)
        if row_error
          errors << row_error
          rows_rejected += 1
          next
        end

        attrs[:program_id] = @program.id
        attrs[:ops_import_id] = import.id
        attrs[:source_row_number] = row_number

        REPORT_CONFIG.fetch(@report_type).fetch(:model).create!(attrs)
        rows_imported += 1
      rescue ActiveRecord::RecordInvalid => e
        errors << "Row #{row_number}: #{e.record.errors.full_messages.join(', ')}"
        rows_rejected += 1
      end

      if errors.any?
        raise ActiveRecord::Rollback
      end
    end

    if errors.any?
      Result.new(ok: false, import: nil, errors: errors)
    else
      import.update!(rows_imported: rows_imported, rows_rejected: rows_rejected, status: "completed") if import
      Result.new(ok: true, import: import, errors: [])
    end
  rescue StandardError => e
    Result.new(ok: false, import: nil, errors: [ "Import crashed: #{e.class} - #{e.message}" ])
  end

  private

  def load_sheet
    spreadsheet = Roo::Spreadsheet.open(@file.tempfile.path, extension: file_extension)
    spreadsheet.sheet(0)
  rescue StandardError
    nil
  end

  def file_extension
    File.extname(@file.original_filename.to_s).delete(".")
  end

  def header_index_map(sheet)
    headers = sheet.row(1).map { |value| normalize_header(value) }
    headers.each_with_index.to_h
  end

  def normalize_header(value)
    value.to_s.strip.downcase.gsub(/\s+/, "_")
  end

  def blank_row?(values)
    values.compact.all? { |value| value.to_s.strip.empty? }
  end

  def each_sheet_row(sheet)
    if sheet.respond_to?(:each_row_streaming)
      row_index = 1
      sheet.each_row_streaming(offset: 1, pad_cells: true) do |row|
        row_index += 1
        values = row.map { |cell| cell&.value }
        yield row_index, values
      end
    else
      (2..sheet.last_row.to_i).each do |row_index|
        values = sheet.row(row_index)
        yield row_index, values
      end
    end
  end

  def required_headers
    REPORT_CONFIG.fetch(@report_type).fetch(:required)
  end

  def build_attrs(values, header_map, row_number)
    attrs = case @report_type
    when "materials"
      material_attrs(values, header_map)
    when "shop_orders"
      shop_order_attrs(values, header_map)
    when "shop_order_operations"
      shop_order_operation_attrs(values, header_map)
    when "historical_efficiency"
      historical_efficiency_attrs(values, header_map)
    when "scrap"
      scrap_attrs(values, header_map)
    when "mrb_part_details"
      mrb_part_attrs(values, header_map)
    when "mrb_dispo_lines"
      mrb_dispo_attrs(values, header_map)
    when "bom"
      bom_attrs(values, header_map)
    else
      {}
    end

    required_headers.each do |key|
      value = attrs[key.to_sym]
      if value.nil? || value.to_s.strip.empty?
        return [ attrs, "Row #{row_number}: #{key} is required." ]
      end
    end

    [ attrs, nil ]
  end

  def material_attrs(values, header_map)
    {
      part_number: fetch(values, header_map, "part_number"),
      part_description: fetch(values, header_map, "part_description"),
      supplier: fetch(values, header_map, "supplier"),
      commodity: fetch(values, header_map, "commodity"),
      buyer: fetch(values, header_map, "buyer"),
      purchase_order: fetch(values, header_map, "purchase_order"),
      order_date: to_date(fetch(values, header_map, "order_date")),
      need_date: to_date(fetch(values, header_map, "need_date")),
      receipt_date: to_date(fetch(values, header_map, "receipt_date")),
      quantity_ordered: to_decimal(fetch(values, header_map, "quantity_ordered")),
      quantity_received: to_decimal(fetch(values, header_map, "quantity_received")),
      unit_cost: to_decimal(fetch(values, header_map, "unit_cost")),
      extended_cost: to_decimal(fetch(values, header_map, "extended_cost")),
      lead_time_days: to_integer(fetch(values, header_map, "lead_time_days"))
    }
  end

  def shop_order_attrs(values, header_map)
    {
      order_number: fetch(values, header_map, "order_number"),
      release_number: fetch(values, header_map, "release_number"),
      status: fetch(values, header_map, "status"),
      part_number: fetch(values, header_map, "part_number"),
      part_description: fetch(values, header_map, "part_description"),
      work_center: fetch(values, header_map, "work_center"),
      planned_start: to_date(fetch(values, header_map, "planned_start")),
      planned_finish: to_date(fetch(values, header_map, "planned_finish")),
      actual_start: to_date(fetch(values, header_map, "actual_start")),
      actual_finish: to_date(fetch(values, header_map, "actual_finish")),
      due_date: to_date(fetch(values, header_map, "due_date")),
      order_quantity: to_decimal(fetch(values, header_map, "order_quantity")),
      completed_quantity: to_decimal(fetch(values, header_map, "completed_quantity")),
      remaining_quantity: to_decimal(fetch(values, header_map, "remaining_quantity")),
      estimated_hours: to_decimal(fetch(values, header_map, "estimated_hours")),
      actual_hours: to_decimal(fetch(values, header_map, "actual_hours"))
    }
  end

  def shop_order_operation_attrs(values, header_map)
    {
      order_number: fetch(values, header_map, "order_number"),
      operation_number: fetch(values, header_map, "operation_number"),
      sequence: fetch(values, header_map, "sequence"),
      status: fetch(values, header_map, "status"),
      work_center: fetch(values, header_map, "work_center"),
      scheduled_start: to_date(fetch(values, header_map, "scheduled_start")),
      scheduled_finish: to_date(fetch(values, header_map, "scheduled_finish")),
      actual_start: to_date(fetch(values, header_map, "actual_start")),
      actual_finish: to_date(fetch(values, header_map, "actual_finish")),
      setup_hours: to_decimal(fetch(values, header_map, "setup_hours")),
      run_hours: to_decimal(fetch(values, header_map, "run_hours")),
      labor_hours: to_decimal(fetch(values, header_map, "labor_hours")),
      queue_time: to_decimal(fetch(values, header_map, "queue_time"))
    }
  end

  def historical_efficiency_attrs(values, header_map)
    {
      period_start: to_date(fetch(values, header_map, "period_start")),
      period_end: to_date(fetch(values, header_map, "period_end")),
      labor_category: fetch(values, header_map, "labor_category"),
      work_center: fetch(values, header_map, "work_center"),
      planned_hours: to_decimal(fetch(values, header_map, "planned_hours")),
      actual_hours: to_decimal(fetch(values, header_map, "actual_hours")),
      variance_hours: to_decimal(fetch(values, header_map, "variance_hours")),
      efficiency_percent: to_decimal(fetch(values, header_map, "efficiency_percent"))
    }
  end

  def scrap_attrs(values, header_map)
    {
      scrap_date: to_date(fetch(values, header_map, "scrap_date")),
      part_number: fetch(values, header_map, "part_number"),
      part_description: fetch(values, header_map, "part_description"),
      reason_code: fetch(values, header_map, "reason_code"),
      shop_order_number: fetch(values, header_map, "shop_order_number"),
      scrap_quantity: to_decimal(fetch(values, header_map, "scrap_quantity")),
      scrap_cost: to_decimal(fetch(values, header_map, "scrap_cost"))
    }
  end

  def mrb_part_attrs(values, header_map)
    {
      mrb_number: fetch(values, header_map, "mrb_number"),
      line_number: fetch(values, header_map, "line_number"),
      status: fetch(values, header_map, "status"),
      disposition: fetch(values, header_map, "disposition"),
      part_number: fetch(values, header_map, "part_number"),
      part_description: fetch(values, header_map, "part_description"),
      supplier: fetch(values, header_map, "supplier"),
      created_date: to_date(fetch(values, header_map, "created_date")),
      closed_date: to_date(fetch(values, header_map, "closed_date")),
      quantity: to_decimal(fetch(values, header_map, "quantity")),
      unit_cost: to_decimal(fetch(values, header_map, "unit_cost")),
      extended_cost: to_decimal(fetch(values, header_map, "extended_cost"))
    }
  end

  def mrb_dispo_attrs(values, header_map)
    {
      mrb_number: fetch(values, header_map, "mrb_number"),
      line_number: fetch(values, header_map, "line_number"),
      disposition: fetch(values, header_map, "disposition"),
      responsible: fetch(values, header_map, "responsible"),
      disposition_date: to_date(fetch(values, header_map, "disposition_date")),
      disposition_quantity: to_decimal(fetch(values, header_map, "disposition_quantity")),
      disposition_cost: to_decimal(fetch(values, header_map, "disposition_cost"))
    }
  end

  def bom_attrs(values, header_map)
    {
      parent_part_number: fetch(values, header_map, "parent_part_number"),
      component_part_number: fetch(values, header_map, "component_part_number"),
      component_description: fetch(values, header_map, "component_description"),
      unit: fetch(values, header_map, "unit"),
      level: to_integer(fetch(values, header_map, "level")),
      quantity_per: to_decimal(fetch(values, header_map, "quantity_per")),
      effective_from: to_date(fetch(values, header_map, "effective_from")),
      effective_to: to_date(fetch(values, header_map, "effective_to"))
    }
  end

  def fetch(values, header_map, key)
    index = header_map[key]
    return nil if index.nil?

    values[index]
  end

  def to_date(value)
    return nil if value.nil? || value.to_s.strip.empty?
    return value.to_date if value.respond_to?(:to_date)

    Date.parse(value.to_s)
  rescue ArgumentError
    nil
  end

  def to_decimal(value)
    return nil if value.nil? || value.to_s.strip.empty?

    BigDecimal(value.to_s)
  rescue ArgumentError
    nil
  end

  def to_integer(value)
    return nil if value.nil? || value.to_s.strip.empty?

    value.to_i
  end
end
