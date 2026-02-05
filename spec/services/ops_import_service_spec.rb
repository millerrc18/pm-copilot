require "rails_helper"
require "csv"

RSpec.describe OpsImportService do
  def build_upload(headers, rows)
    file = Tempfile.new([ "ops-import", ".csv" ])
    file.write(CSV.generate do |csv|
      csv << headers
      rows.each { |row| csv << row }
    end)
    file.rewind
    Rack::Test::UploadedFile.new(file.path, "text/csv", original_filename: "ops.csv")
  end

  it "rejects missing required headers" do
    user = User.create!(email: "ops-import@example.com", password: "password")
    program = Program.create!(name: "Ops Program", user: user)

    file = build_upload([ "part_number" ], [ [ "PN-1" ] ])
    result = described_class.new(user: user, program: program, report_type: "materials", file: file).call

    expect(result.ok).to be(false)
    expect(result.errors.first).to include("Missing required column")
  end

  it "imports materials rows" do
    user = User.create!(email: "ops-import-2@example.com", password: "password")
    program = Program.create!(name: "Ops Program", user: user)

    headers = OpsImportService::TEMPLATE_HEADERS.fetch("materials")
    file = build_upload(
      headers,
      [ [ "PN-1", "Bracket", "Acme", "Steel", "Buyer", "PO-1", "2024-01-01", "2024-01-03", "2024-01-05", 5, 5, 10, 50, 3 ] ]
    )

    result = described_class.new(user: user, program: program, report_type: "materials", file: file).call

    expect(result.ok).to be(true)
    expect(OpsMaterial.count).to eq(1)
    expect(OpsImport.count).to eq(1)
  end

  it "blocks duplicate imports" do
    user = User.create!(email: "ops-import-dup@example.com", password: "password")
    program = Program.create!(name: "Ops Program", user: user)

    headers = OpsImportService::TEMPLATE_HEADERS.fetch("scrap")
    file = build_upload(
      headers,
      [ [ "2024-01-05", "PN-1", "Bracket", "Scratch", "SO-1", 1, 25 ] ]
    )

    first = described_class.new(user: user, program: program, report_type: "scrap", file: file).call
    second = described_class.new(user: user, program: program, report_type: "scrap", file: file).call

    expect(first.ok).to be(true)
    expect(second.ok).to be(false)
    expect(second.errors.first).to include("already been imported")
  end
end
