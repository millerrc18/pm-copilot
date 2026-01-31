require "rails_helper"

RSpec.describe CostImportService do
  class FakeSheet
    def initialize(rows)
      @rows = rows
    end

    def row(index)
      @rows[index - 1]
    end

    def last_row
      @rows.length
    end
  end

  let(:user) { User.create!(email: "costs@example.com", password: "password") }
  let(:program) { Program.create!(name: "Program", user: user) }

  def build_row(period_type: "week", period_start_date: Date.new(2024, 1, 1))
    headers = described_class::REQUIRED_HEADERS
    headers.map do |header|
      case header
      when "period_type"
        period_type
      when "period_start_date"
        period_start_date
      when "notes"
        "Imported"
      else
        1
      end
    end
  end

  it "imports costs for the program" do
    headers = described_class::REQUIRED_HEADERS
    rows = [headers, build_row]
    sheet = FakeSheet.new(rows)

    service = described_class.new(user: user, program: program, file: double("file"))
    allow(service).to receive(:load_sheet).and_return(sheet)

    result = service.call

    expect(result[:created]).to eq(1)
    expect(CostEntry.count).to eq(1)
    expect(CostEntry.first.program).to eq(program)
  end

  it "rolls back when a row is invalid" do
    headers = described_class::REQUIRED_HEADERS
    rows = [
      headers,
      build_row,
      build_row(period_type: "quarter")
    ]
    sheet = FakeSheet.new(rows)

    service = described_class.new(user: user, program: program, file: double("file"))
    allow(service).to receive(:load_sheet).and_return(sheet)

    result = service.call

    expect(result[:created]).to eq(0)
    expect(result[:errors].join(" ")).to include("period_type")
    expect(CostEntry.count).to eq(0)
  end
end
