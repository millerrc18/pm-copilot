# frozen_string_literal: true

require "roo"
require "bigdecimal/util"

class DeliveryUnitImportService
  REQUIRED_HEADERS = %w[contract_code unit_serial ship_date notes].freeze

  def initialize(user:, program:, file:)
    @user = user
    @program = program
    @file = file
  end

  def call
    errors = []

    if @program.nil?
      return { created: 0, updated: 0, errors: [ "Program is required for delivery unit imports." ] }
    end

    if @program.user_id != @user.id
      return { created: 0, updated: 0, errors: [ "Not authorized to import delivery units for this program." ] }
    end

    sheet = load_sheet(@file)
    headers = normalize_headers(sheet.row(1))
    index = header_index!(headers, REQUIRED_HEADERS)

    created = 0
    updated = 0

    DeliveryUnit.transaction do
      2.upto(sheet.last_row) do |row_num|
        row = sheet.row(row_num)
        next if blank_row?(row)

        contract_code = cell(row, index["contract_code"]).to_s.strip
        unit_serial   = cell(row, index["unit_serial"]).to_s.strip
        ship_date     = parse_date(cell(row, index["ship_date"]))
        notes         = cell(row, index["notes"]).to_s.strip

        next if unit_serial.empty? && contract_code.empty? && ship_date.nil? && notes.empty?

        if contract_code.empty?
          errors << "Row #{row_num}: contract_code is required."
          next
        end

        contract = @program.contracts.find_by(contract_code: contract_code)
        if contract.nil?
          errors << "Row #{row_num}: contract_code '#{contract_code}' not found for the selected program."
          next
        end

        if unit_serial.empty?
          errors << "Row #{row_num}: unit_serial is required."
          next
        end

        record = DeliveryUnit.find_or_initialize_by(contract_id: contract.id, unit_serial: unit_serial)
        was_new = record.new_record?

        record.ship_date = ship_date
        record.notes = notes

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
end
