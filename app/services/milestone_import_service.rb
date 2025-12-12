# frozen_string_literal: true

require "roo"
require "bigdecimal/util"

class MilestoneImportService
  REQUIRED_HEADERS = %w[
    contract_code milestone_ref promise_date quantity_due notes
    amendment_code amendment_effective_date amendment_notes
  ].freeze

  def initialize(user:, contract:, file:)
    @user = user
    @contract = contract
    @file = file
  end

  def call
    authorize!

    sheet = load_sheet(@file)
    headers = normalize_headers(sheet.row(1))
    index = header_index!(headers, REQUIRED_HEADERS)

    created = 0
    updated = 0

    DeliveryMilestone.transaction do
      2.upto(sheet.last_row) do |row_num|
        row = sheet.row(row_num)
        next if blank_row?(row)

        contract_code = cell(row, index["contract_code"]).to_s.strip
        milestone_ref = cell(row, index["milestone_ref"]).to_s.strip
        promise_date  = parse_date(cell(row, index["promise_date"]))
        quantity_due  = to_i(cell(row, index["quantity_due"]))
        notes         = cell(row, index["notes"]).to_s.strip

        amendment_code = cell(row, index["amendment_code"]).to_s.strip
        amendment_effective_date = parse_date(cell(row, index["amendment_effective_date"]))
        amendment_notes = cell(row, index["amendment_notes"]).to_s.strip

        validate_contract_code!(contract_code, row_num)

        if milestone_ref.empty?
          raise "Row #{row_num}: milestone_ref is required (stable ID like FY25-JAN)."
        end

        if promise_date.nil?
          raise "Row #{row_num}: promise_date is required."
        end

        if quantity_due <= 0
          raise "Row #{row_num}: quantity_due must be > 0."
        end

        record = DeliveryMilestone.find_or_initialize_by(
          contract_id: @contract.id,
          milestone_ref: milestone_ref
        )
        was_new = record.new_record?

        record.due_date = promise_date
        record.quantity_due = quantity_due
        record.notes = notes

        record.amendment_code = amendment_code if record.respond_to?(:amendment_code=)
        record.amendment_effective_date = amendment_effective_date if record.respond_to?(:amendment_effective_date=)
        record.amendment_notes = amendment_notes if record.respond_to?(:amendment_notes=)

        record.save!

        was_new ? created += 1 : updated += 1
      end
    end

    { created: created, updated: updated }
  end

  private

  def authorize!
    unless @contract.program.user_id == @user.id
      raise "Not authorized for this contract."
    end
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

  def to_i(v)
    return 0 if v.nil? || v.to_s.strip.empty?
    Integer(v)
  rescue ArgumentError, TypeError
    raise "Invalid integer: #{v}"
  end

  def validate_contract_code!(contract_code, row_num)
    return if contract_code.empty?
    return if contract_code == @contract.contract_code

    raise "Row #{row_num}: contract_code '#{contract_code}' does not match this contract (#{@contract.contract_code})."
  end
end
