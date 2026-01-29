# frozen_string_literal: true

require "bigdecimal/util"

class ContractWorkbookImporter
  SHEET_PERIODS    = "ContractPeriods"
  SHEET_MILESTONES = "DeliveryMilestones"
  SHEET_UNITS      = "DeliveryUnits"
  REQUIRED_PERIOD_HEADERS = %w[period_start_date period_type].freeze
  REQUIRED_MILESTONE_HEADERS = %w[milestone_ref due_date quantity_due].freeze
  REQUIRED_UNIT_HEADERS = %w[unit_serial].freeze

  def initialize(contract:, file:)
    @contract = contract
    @file = file
  end

  def import!
    xlsx = Roo::Excelx.new(@file.tempfile.path)

    missing_sheets = [SHEET_PERIODS, SHEET_MILESTONES, SHEET_UNITS] - xlsx.sheets
    if missing_sheets.any?
      return fail_result(["Missing sheet(s): #{missing_sheets.join(', ')}"])
    end

    result = {
      periods:    { created: 0, updated: 0 },
      milestones: { created: 0, updated: 0 },
      units:      { created: 0, updated: 0 }
    }

    errors = []

    ActiveRecord::Base.transaction do
      errors.concat(import_periods!(xlsx, result[:periods]))
      errors.concat(import_milestones!(xlsx, result[:milestones]))
      errors.concat(import_units!(xlsx, result[:units]))

      raise ActiveRecord::Rollback if errors.any?
    end

    return fail_result(errors) if errors.any?
    { ok: true, result: result, errors: [] }
  rescue StandardError => e
    fail_result(["Import crashed: #{e.class} - #{e.message}"])
  end

  private

  def fail_result(errors)
    { ok: false, result: nil, errors: errors }
  end

  def normalize_header(v)
    v.to_s.strip.downcase.gsub(/\s+/, "_")
  end

  def blank_row?(values)
    values.compact.all? { |v| v.to_s.strip.empty? }
  end

  def to_date(v)
    return nil if v.nil? || v.to_s.strip.empty?
    return v.to_date if v.respond_to?(:to_date)
    Date.parse(v.to_s)
  rescue ArgumentError
    nil
  end

  def to_i0(v)
    return 0 if v.nil? || v.to_s.strip.empty?
    v.to_i
  end

  def to_d0(v)
    return 0.to_d if v.nil? || v.to_s.strip.empty?
    v.to_d
  end

  def header_index_map(sheet)
    headers = sheet.row(1).map { |h| normalize_header(h) }
    map = {}
    headers.each_with_index { |h, i| map[h] = i }
    map
  end

  # -------------------------
  # Periods
  # -------------------------
  def import_periods!(xlsx, counts)
    sheet = xlsx.sheet(SHEET_PERIODS)
    idx = header_index_map(sheet)

    missing = REQUIRED_PERIOD_HEADERS.reject { |h| idx.key?(h) }
    return ["#{SHEET_PERIODS}: missing required column(s): #{missing.join(', ')}"] if missing.any?

    seen_keys = {}
    errors = []

    xlsx.default_sheet = SHEET_PERIODS
    excel_row = 2

    # Roo: each_row_streaming supports offset and pad_cells :contentReference[oaicite:1]{index=1}
    xlsx.each_row_streaming(offset: 1, pad_cells: true) do |row|
      values = row.map { |c| c&.value }
      if blank_row?(values)
        excel_row += 1
        next
      end

      start_date = to_date(values[idx["period_start_date"]])
      period_type = values[idx["period_type"]].to_s.strip.downcase

      if start_date.nil?
        errors << "#{SHEET_PERIODS} row #{excel_row}: period_start_date is blank or invalid."
        excel_row += 1
        next
      end

      if period_type != "week" && period_type != "month"
        errors << "#{SHEET_PERIODS} row #{excel_row}: period_type must be week or month."
        excel_row += 1
        next
      end

      key = "#{start_date}|#{period_type}"
      if seen_keys[key]
        errors << "#{SHEET_PERIODS} row #{excel_row}: duplicate (period_start_date + period_type) in workbook."
        excel_row += 1
        next
      end
      seen_keys[key] = true

      attrs = {
        units_delivered:   to_i0(values[idx["units_delivered"]]),
        revenue_per_unit:  to_d0(values[idx["revenue_per_unit"]]),
        hours_bam:         to_d0(values[idx["hours_bam"]]),
        rate_bam:          to_d0(values[idx["rate_bam"]]),
        hours_eng:         to_d0(values[idx["hours_eng"]]),
        rate_eng:          to_d0(values[idx["rate_eng"]]),
        hours_mfg_soft:    to_d0(values[idx["hours_mfg_soft"]]),
        rate_mfg_soft:     to_d0(values[idx["rate_mfg_soft"]]),
        hours_mfg_hard:    to_d0(values[idx["hours_mfg_hard"]]),
        rate_mfg_hard:     to_d0(values[idx["rate_mfg_hard"]]),
        hours_touch:       to_d0(values[idx["hours_touch"]]),
        rate_touch:        to_d0(values[idx["rate_touch"]]),
        material_cost:     to_d0(values[idx["material_cost"]]),
        other_costs:       to_d0(values[idx["other_costs"]]),
      }

      record = ContractPeriod.find_or_initialize_by(
        contract: @contract,
        period_start_date: start_date,
        period_type: period_type
      )

      was_new = record.new_record?
      record.assign_attributes(attrs)

      unless record.save
        errors << "#{SHEET_PERIODS} row #{excel_row}: #{record.errors.full_messages.join(', ')}"
      else
        was_new ? counts[:created] += 1 : counts[:updated] += 1
      end

      excel_row += 1
    end

    errors
  end

  # -------------------------
  # Milestones
  # -------------------------
  def import_milestones!(xlsx, counts)
    sheet = xlsx.sheet(SHEET_MILESTONES)
    idx = header_index_map(sheet)

    missing = REQUIRED_MILESTONE_HEADERS.reject { |h| idx.key?(h) }
    return ["#{SHEET_MILESTONES}: missing required column(s): #{missing.join(', ')}"] if missing.any?

    seen_keys = {}
    errors = []

    xlsx.default_sheet = SHEET_MILESTONES
    excel_row = 2

    xlsx.each_row_streaming(offset: 1, pad_cells: true) do |row|
      values = row.map { |c| c&.value }
      if blank_row?(values)
        excel_row += 1
        next
      end

      milestone_ref = values[idx["milestone_ref"]].to_s.strip
      due_date = to_date(values[idx["due_date"]])
      qty_due = to_i0(values[idx["quantity_due"]])
      notes = idx["notes"] ? values[idx["notes"]].to_s : nil
      amendment_code = idx["amendment_code"] ? values[idx["amendment_code"]].to_s.strip : nil
      amendment_effective_date = idx["amendment_effective_date"] ? to_date(values[idx["amendment_effective_date"]]) : nil
      amendment_notes = idx["amendment_notes"] ? values[idx["amendment_notes"]].to_s : nil

      if milestone_ref.empty?
        errors << "#{SHEET_MILESTONES} row #{excel_row}: milestone_ref is required."
        excel_row += 1
        next
      end

      if due_date.nil?
        errors << "#{SHEET_MILESTONES} row #{excel_row}: due_date is blank or invalid."
        excel_row += 1
        next
      end

      if idx["amendment_effective_date"] && values[idx["amendment_effective_date"]] && amendment_effective_date.nil?
        errors << "#{SHEET_MILESTONES} row #{excel_row}: amendment_effective_date is invalid."
        excel_row += 1
        next
      end

      key = milestone_ref
      if seen_keys[key]
        errors << "#{SHEET_MILESTONES} row #{excel_row}: duplicate milestone_ref in workbook."
        excel_row += 1
        next
      end
      seen_keys[key] = true

      record = DeliveryMilestone.find_or_initialize_by(contract: @contract, milestone_ref: milestone_ref)
      was_new = record.new_record?

      record.assign_attributes(
        due_date: due_date,
        quantity_due: qty_due,
        notes: notes
      )

      if record.respond_to?(:amendment_code=)
        record.amendment_code = amendment_code if idx["amendment_code"]
        if idx["amendment_effective_date"]
          record.amendment_effective_date = amendment_effective_date
        end
        record.amendment_notes = amendment_notes if idx["amendment_notes"]
      end

      unless record.save
        errors << "#{SHEET_MILESTONES} row #{excel_row}: #{record.errors.full_messages.join(', ')}"
      else
        was_new ? counts[:created] += 1 : counts[:updated] += 1
      end

      excel_row += 1
    end

    errors
  end

  # -------------------------
  # Units (unit-level shipments)
  # -------------------------
  def import_units!(xlsx, counts)
    sheet = xlsx.sheet(SHEET_UNITS)
    idx = header_index_map(sheet)

    missing = REQUIRED_UNIT_HEADERS.reject { |h| idx.key?(h) }
    return ["#{SHEET_UNITS}: missing required column(s): #{missing.join(', ')}"] if missing.any?

    seen_keys = {}
    errors = []

    xlsx.default_sheet = SHEET_UNITS
    excel_row = 2

    xlsx.each_row_streaming(offset: 1, pad_cells: true) do |row|
      values = row.map { |c| c&.value }
      if blank_row?(values)
        excel_row += 1
        next
      end

      unit_serial = values[idx["unit_serial"]].to_s.strip
      ship_date = idx["ship_date"] ? to_date(values[idx["ship_date"]]) : nil
      notes = idx["notes"] ? values[idx["notes"]].to_s : nil

      if unit_serial.empty?
        errors << "#{SHEET_UNITS} row #{excel_row}: unit_serial is required."
        excel_row += 1
        next
      end

      if seen_keys[unit_serial]
        errors << "#{SHEET_UNITS} row #{excel_row}: duplicate unit_serial in workbook."
        excel_row += 1
        next
      end
      seen_keys[unit_serial] = true

      record = DeliveryUnit.find_or_initialize_by(contract: @contract, unit_serial: unit_serial)
      was_new = record.new_record?

      # ship_date is allowed to be blank (nil) so you can preload unit serials
      record.assign_attributes(ship_date: ship_date, notes: notes)

      unless record.save
        errors << "#{SHEET_UNITS} row #{excel_row}: #{record.errors.full_messages.join(', ')}"
      else
        was_new ? counts[:created] += 1 : counts[:updated] += 1
      end

      excel_row += 1
    end

    errors
  end
end
