# frozen_string_literal: true

require "roo"
require "bigdecimal/util"

class DeliveryUnitImportService
  REQUIRED_HEADERS = %w[contract_code unit_serial ship_date notes].freeze

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

    DeliveryUnit.transaction do
      2.upto(sheet.last_row) do |row_num|
        row = sheet.row(row_num)
        next if blank_row?(row)

        contract_code = cell(row, index["contract_code"]).to_s.strip
        unit_serial   = cell(row, index["unit_serial"]).to_s.strip
        ship_date     = parse_date(cell(row, index["ship_date"]))
        notes         = cell(row, index["notes"]).to_s.strip

        next if unit_serial.empty? && contract_code.empty? && ship_date.nil? && notes.empty?

        validate_contract_code!(contract_code, row_num)

        if unit_serial.empty?
          raise "Row #{row_num}: unit_serial is required."
        end

        record = DeliveryUnit.find_or_initialize_by(contract_id: @contract.id, unit_serial: unit_serial)
        was_new = record.new_record?

        record.ship_date = ship_date
        record.notes = notes
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

  def validate_contract_code!(contract_code, row_num)
    return if contract_code.empty?
    return if contract_code == @contract.contract_code

    raise "Row #{row_num}: contract_code '#{contract_code}' does not match this contract (#{@contract.contract_code})."
  end
end
