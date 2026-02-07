require "rails_helper"
require "caxlsx"

RSpec.describe OpsImportService do
  def build_workbook(headers, rows)
    file = Tempfile.new([ "ops-import", ".xlsx" ])
    package = Axlsx::Package.new
    package.workbook.add_worksheet(name: "Sheet1") do |sheet|
      sheet.add_row(headers)
      rows.each { |row| sheet.add_row(row) }
    end
    package.serialize(file.path)
    file
  end

  it "rejects missing required headers" do
    user = User.create!(email: "ops-import@example.com", password: "password")
    program = Program.create!(name: "Ops Program", user: user)
    import = OpsImport.create!(program: program, imported_by: user, report_type: "materials", checksum: "abc123", status: "running")

    file = build_workbook([ "part_number" ], [ [ "PN-1" ] ])
    result = described_class.new(import: import, report_type: "materials", file_path: file.path).call

    expect(result.ok).to be(false)
    expect(result.errors.first).to include("Missing required column")
  end

  it "imports materials rows" do
    user = User.create!(email: "ops-import-2@example.com", password: "password")
    program = Program.create!(name: "Ops Program", user: user)
    import = OpsImport.create!(program: program, imported_by: user, report_type: "materials", checksum: "abc124", status: "running")

    headers = OpsImportService::TEMPLATE_HEADERS.fetch("materials")
    file = build_workbook(
      headers,
      [ [ "PN-1", "Bracket", "Acme", "Steel", "Buyer", "PO-1", "2024-01-01", "2024-01-03", "2024-01-05", 5, 5, 10, 50, 3 ] ]
    )

    result = described_class.new(import: import, report_type: "materials", file_path: file.path).call

    expect(result.ok).to be(true)
    expect(OpsMaterial.count).to eq(1)
  end

  it "batches inserts using insert_all" do
    user = User.create!(email: "ops-import-3@example.com", password: "password")
    program = Program.create!(name: "Ops Program", user: user)
    import = OpsImport.create!(program: program, imported_by: user, report_type: "materials", checksum: "abc125", status: "running")

    cell = Struct.new(:value)
    headers = OpsImportService::REPORT_CONFIG.fetch("materials").fetch(:required)
    rows = [
      headers.map { |header| cell.new(header) },
      [
        cell.new("PN-1"),
        cell.new("Acme"),
        cell.new(Date.new(2024, 1, 1)),
        cell.new(1),
        cell.new(2),
        cell.new(2)
      ]
    ]

    sheet = instance_double(Roo::Excelx)
    allow(sheet).to receive(:each_row_streaming).and_yield(rows[0]).and_yield(rows[1])
    allow(sheet).to receive(:sheet).and_return(sheet)
    allow(Roo::Excelx).to receive(:new).and_return(sheet)

    expect(OpsMaterial).to receive(:insert_all).with(
      array_including(hash_including(part_number: "PN-1")),
      record_timestamps: true
    ).and_return([])

    result = described_class.new(import: import, report_type: "materials", file_path: "fake.xlsx").call

    expect(result.ok).to be(true)
  end
end
