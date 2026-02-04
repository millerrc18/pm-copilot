require "rails_helper"

RSpec.describe Risk, type: :model do
  it "requires a program and allows an optional contract" do
    user = User.create!(email: "risk-scope@example.com", password: "password")
    program = Program.create!(name: "Risk Program", user: user)
    contract = Contract.create!(
      program: program,
      contract_code: "RSK-001",
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 12, 31),
      sell_price_per_unit: 100
    )

    risk = described_class.new(
      title: "Scope gap",
      risk_type: "risk",
      probability: 3,
      impact: 4,
      status: "open"
    )
    expect(risk).not_to be_valid

    risk.program = program
    expect(risk).to be_valid

    risk.contract = contract
    expect(risk).to be_valid

    other_program = Program.create!(name: "Other Program", user: user)
    other_contract = Contract.create!(
      program: other_program,
      contract_code: "RSK-002",
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 12, 31),
      sell_price_per_unit: 100
    )
    risk.contract = other_contract
    expect(risk).not_to be_valid
  end

  it "calculates severity score from probability and impact" do
    user = User.create!(email: "risk-score@example.com", password: "password")
    program = Program.create!(name: "Risk Program", user: user)

    risk = described_class.new(
      title: "Delivery risk",
      risk_type: "risk",
      probability: 2,
      impact: 5,
      status: "open",
      program: program
    )

    risk.validate
    expect(risk.severity_score).to eq(10)
    expect(risk.severity_label).to eq("Medium")
  end

  it "calculates exposure totals using open items" do
    user = User.create!(email: "risk-exposure@example.com", password: "password")
    program = Program.create!(name: "Risk Program", user: user)

    described_class.create!(
      title: "Risk A",
      risk_type: "risk",
      probability: 3,
      impact: 3,
      status: "open",
      program: program
    )
    described_class.create!(
      title: "Risk B",
      risk_type: "risk",
      probability: 2,
      impact: 2,
      status: "closed",
      program: program
    )
    described_class.create!(
      title: "Opportunity A",
      risk_type: "opportunity",
      probability: 4,
      impact: 2,
      status: "open",
      program: program
    )

    scope = described_class.where(program_id: program.id)
    totals = described_class.exposure_totals(scope)

    expect(totals[:risk_total]).to eq(9)
    expect(totals[:opportunity_total]).to eq(8)
    expect(totals[:net_exposure]).to eq(-1)
  end
end
