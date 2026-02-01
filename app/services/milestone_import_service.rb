# frozen_string_literal: true

require "roo"
require "bigdecimal/util"

class MilestoneImportService
  REQUIRED_HEADERS = %w[
    contract_code milestone_ref promise_date quantity_due notes
    amendment_code amendment_effective_date amendment_notes
  ].freeze

  def initialize(user:, program:, file:)
    @user = user
    @program = program
    @file = file
  end

  def call
    errors = []

    if @program.nil?
      return { created: 0, updated: 0, errors: [ "Program is required for milestone imports." ] }
    end

    if @program.user_id != @user.id
      return { created: 0, updated: 0, errors: [ "Not authorized to import milestones for this program." ] }
    end

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

        if contract_code.empty?
          errors << "Row #{row_num}: contract_code is required."
          next
        end

        contract = @program.contracts.find_by(contract_code: contract_code)
        if contract.nil?
          errors << "Row #{row_num}: contract_code '#{contract_code}' not found for the selected program."
          next
        end

        if milestone_ref.empty?
          errors << "Row #{row_num}: milestone_ref is required (stable ID like FY25-JAN)."
          next
        end

        if promise_date.nil?
          errors << "Row #{row_num}: promise_date is required."
          next
        end

        if quantity_due <= 0
          errors << "Row #{row_num}: quantity_due must be > 0."
          next
        end

        record = DeliveryMilestone.find_or_initialize_by(
          contract_id: contract.id,
          milestone_ref: milestone_ref
        )
        was_new = record.new_record?

        record.due_date = promise_date
        record.quantity_due = quantity_due
        record.notes = notes

        record.amendment_code = amendment_code if record.respond_to?(:amendment_code=)
        record.amendment_effective_date = amendment_effective_date if record.respond_to?(:amendment_effective_date=)
        record.amendment_notes = amendment_notes if record.respond_to?(:amendment_notes=)

        if record.valid?
          record.save!
          was_new ? created += 1 : updated += 1
        else
          errors << "Row #{row_num}: #{record.errors.full_messages.to_sentence}."
        end
      rescue StandardError => e
        errors << "Row #{row_num}: #{e.message}."
      end

      raise ActiveRecord::Rollback if errors.any?
    end

    { created: errors.any? ? 0 : created, updated: errors.any? ? 0 : updated, errors: errors }
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

  def to_i(v)
    return 0 if v.nil? || v.to_s.strip.empty?
    Integer(v)
  rescue ArgumentError, TypeError
    raise "Invalid integer: #{v}"
  end
end
