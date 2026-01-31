# frozen_string_literal: true

require "roo"
require "bigdecimal/util"

class CostImportService
  REQUIRED_HEADERS = %w[
    period_type period_start_date
    hours_bam hours_eng hours_mfg_salary hours_mfg_hourly hours_touch
    rate_bam rate_eng rate_mfg_salary rate_mfg_hourly rate_touch
    material_cost other_costs notes
  ].freeze

  ALLOWED_PERIOD_TYPES = %w[week month].freeze

  def initialize(user:, program: nil, file:)
    @user = user
    @program = program
    @file = file
  end

  def call
    if @program && @program.user_id != @user.id
      return { created: 0, errors: [ "Not authorized to import costs for this program." ] }
    end

    sheet = load_sheet(@file)
    headers = normalize_headers(sheet.row(1))
    index = header_index!(headers, REQUIRED_HEADERS)

    created = 0
    errors = []

    CostEntry.transaction do
      2.upto(sheet.last_row) do |row_num|
        row = sheet.row(row_num)
        next if blank_row?(row)

        period_type = cell(row, index["period_type"]).to_s.strip.downcase
        period_start_date = parse_date(cell(row, index["period_start_date"]))
        notes = cell(row, index["notes"]).to_s.strip

        if period_type.present? && !ALLOWED_PERIOD_TYPES.include?(period_type)
          errors << "Row #{row_num}: period_type must be 'week' or 'month'."
          next
        end

        record = CostEntry.new(
          period_type: period_type.presence,
          period_start_date: period_start_date,
          hours_bam: to_d(cell(row, index["hours_bam"])),
          hours_eng: to_d(cell(row, index["hours_eng"])),
          hours_mfg_salary: to_d(cell(row, index["hours_mfg_salary"])),
          hours_mfg_hourly: to_d(cell(row, index["hours_mfg_hourly"])),
          hours_touch: to_d(cell(row, index["hours_touch"])),
          rate_bam: to_d(cell(row, index["rate_bam"])),
          rate_eng: to_d(cell(row, index["rate_eng"])),
          rate_mfg_salary: to_d(cell(row, index["rate_mfg_salary"])),
          rate_mfg_hourly: to_d(cell(row, index["rate_mfg_hourly"])),
          rate_touch: to_d(cell(row, index["rate_touch"])),
          material_cost: to_d(cell(row, index["material_cost"])),
          other_costs: to_d(cell(row, index["other_costs"])),
          notes: notes,
          program: @program
        )

        if record.valid?
          record.save!
          created += 1
        else
          errors << "Row #{row_num}: #{record.errors.full_messages.to_sentence}."
        end
      rescue StandardError => e
        errors << "Row #{row_num}: #{e.message}."
      end

      raise ActiveRecord::Rollback if errors.any?
    end

    { created: errors.any? ? 0 : created, errors: errors }
  end

  private

  def load_sheet(file)
    path = file.respond_to?(:tempfile) ? file.tempfile.path : file.path
    Roo::Excelx.new(path).sheet(0)
  end

  def normalize_headers(row)
    row.map { |h| h.to_s.strip.downcase }
  end

  def header_index!(headers, required)
    required.each do |h|
      raise "Missing required column: #{h}" unless headers.include?(h)
    end

    idx = {}
    required.each { |h| idx[h] = headers.index(h) }
    idx
  end

  def cell(row, idx)
    row[idx]
  end

  def blank_row?(row)
    row.all? { |v| v.nil? || v.to_s.strip.empty? }
  end

  def parse_date(v)
    return nil if v.nil? || v.to_s.strip.empty?
    return v.to_date if v.respond_to?(:to_date)

    Date.parse(v.to_s)
  rescue ArgumentError
    raise "Invalid date: #{v}"
  end

  def to_d(v)
    return nil if v.nil? || v.to_s.strip.empty?
    v.to_d
  rescue ArgumentError
    raise "Invalid number: #{v}"
  end
end
