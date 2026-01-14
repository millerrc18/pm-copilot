# frozen_string_literal: true

require "roo"
require "bigdecimal/util"

class CostImportService
  REQUIRED_HEADERS = %w[
    contract_code period_type period_start_date
    hours_bam hours_eng hours_mfg_soft hours_mfg_hard hours_touch
    rate_bam rate_eng rate_mfg_soft rate_mfg_hard rate_touch
    material_cost other_costs notes
  ].freeze

  ALLOWED_PERIOD_TYPES = %w[week month].freeze

  def initialize(user:, contract: nil, program: nil, file:)
    @user = user
    @contract = contract
    @program = program
    @file = file
  end

  def call
    sheet = load_sheet(@file)
    headers = normalize_headers(sheet.row(1))
    index = header_index!(headers, REQUIRED_HEADERS)

    created = 0
    updated = 0
    per_contract = Hash.new { |hash, key| hash[key] = { created: 0, updated: 0 } }

    ContractPeriod.transaction do
      2.upto(sheet.last_row) do |row_num|
        row = sheet.row(row_num)
        next if blank_row?(row)

        contract_code = cell(row, index["contract_code"]).to_s.strip
        period_type = cell(row, index["period_type"]).to_s.strip.downcase
        period_start_date = parse_date(cell(row, index["period_start_date"]))
        notes = cell(row, index["notes"]).to_s.strip

        contract = resolve_contract!(contract_code, row_num)
        authorize_contract!(contract, row_num)

        if period_type.empty? || !ALLOWED_PERIOD_TYPES.include?(period_type)
          raise "Row #{row_num}: period_type must be 'week' or 'month'."
        end

        if period_start_date.nil?
          raise "Row #{row_num}: period_start_date is required."
        end

        record = ContractPeriod.find_or_initialize_by(
          contract_id: contract.id,
          period_type: period_type,
          period_start_date: period_start_date
        )
        was_new = record.new_record?

        record.hours_bam       = to_d(cell(row, index["hours_bam"]))
        record.hours_eng       = to_d(cell(row, index["hours_eng"]))
        record.hours_mfg_soft  = to_d(cell(row, index["hours_mfg_soft"]))
        record.hours_mfg_hard  = to_d(cell(row, index["hours_mfg_hard"]))
        record.hours_touch     = to_d(cell(row, index["hours_touch"]))

        record.rate_bam        = to_d(cell(row, index["rate_bam"]))
        record.rate_eng        = to_d(cell(row, index["rate_eng"]))
        record.rate_mfg_soft   = to_d(cell(row, index["rate_mfg_soft"]))
        record.rate_mfg_hard   = to_d(cell(row, index["rate_mfg_hard"]))
        record.rate_touch      = to_d(cell(row, index["rate_touch"]))

        record.material_cost   = to_d(cell(row, index["material_cost"]))
        record.other_costs     = to_d(cell(row, index["other_costs"]))
        record.notes           = notes

        # Do not force units/revenue unless nil, to avoid wiping legacy data.
        record.units_delivered = 0 if record.units_delivered.nil?
        record.revenue_per_unit = 0 if record.revenue_per_unit.nil?

        record.save!

        if was_new
          created += 1
          per_contract[contract.contract_code][:created] += 1
        else
          updated += 1
          per_contract[contract.contract_code][:updated] += 1
        end
      end
    end

    { created: created, updated: updated, per_contract: per_contract }
  end

  private

  def authorize_contract!(contract, row_num)
    return if contract.program.user_id == @user.id

    raise "Row #{row_num}: not authorized for contract #{contract.contract_code}."
  end

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
    return 0.to_d if v.nil? || v.to_s.strip.empty?
    v.to_d
  rescue ArgumentError
    raise "Invalid number: #{v}"
  end

  def resolve_contract!(contract_code, row_num)
    if contract_code.empty?
      raise "Row #{row_num}: contract_code is required."
    end

    Contract.find_by!(contract_code: contract_code)
  rescue ActiveRecord::RecordNotFound
    raise "Row #{row_num}: contract_code '#{contract_code}' not found."
  end

  def resolve_contract(contract_code, row_num)
    if @contract
      validate_contract_code!(contract_code, row_num)
      return @contract
    end

    if contract_code.empty?
      raise "Row #{row_num}: contract_code is required."
    end

    contract = Contract.find_by(contract_code: contract_code)
    raise "Row #{row_num}: contract_code '#{contract_code}' was not found." if contract.nil?

    unless contract.program.user_id == @user.id
      raise "Row #{row_num}: not authorized for contract_code '#{contract_code}'."
    end

    contract
  end
end
