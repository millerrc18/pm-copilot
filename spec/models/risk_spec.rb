require "rails_helper"

RSpec.describe Risk, type: :model do
  it "requires either a program or a contract" do
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
end
