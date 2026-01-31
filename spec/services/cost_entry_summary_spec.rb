require "rails_helper"

RSpec.describe CostEntrySummary do
  let(:user) { User.create!(email: "summary@example.com", password: "password") }
  let(:program_a) { Program.create!(name: "Alpha", user: user) }
  let(:program_b) { Program.create!(name: "Beta", user: user) }

  def create_contract(program, code)
    Contract.create!(
      program: program,
      contract_code: code,
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 12, 31),
      sell_price_per_unit: 100,
      planned_quantity: 10
    )
  end

  it "returns zero average cost per unit when no units are delivered" do
    CostEntry.create!(
      program: program_a,
      period_type: "week",
      period_start_date: Date.new(2024, 1, 1),
      material_cost: 100,
      other_costs: 25
    )

    summary = described_class.new(
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 1, 31),
      program: program_a
    ).call

    expect(summary[:total_units]).to eq(0)
    expect(summary[:average_cost_per_unit]).to eq(0.to_d)
  end

  it "filters totals by program" do
    CostEntry.create!(
      program: program_a,
      period_type: "week",
      period_start_date: Date.new(2024, 1, 1),
      material_cost: 100,
      other_costs: 25
    )
    CostEntry.create!(
      program: program_b,
      period_type: "week",
      period_start_date: Date.new(2024, 1, 1),
      material_cost: 50,
      other_costs: 10
    )

    contract_a = create_contract(program_a, "A-1")
    contract_b = create_contract(program_b, "B-1")

    DeliveryUnit.create!(contract: contract_a, unit_serial: "A-001", ship_date: Date.new(2024, 1, 10))
    DeliveryUnit.create!(contract: contract_b, unit_serial: "B-001", ship_date: Date.new(2024, 1, 10))

    summary = described_class.new(
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 1, 31),
      program: program_a
    ).call

    expect(summary[:total_cost]).to eq(125.to_d)
    expect(summary[:total_units]).to eq(1)
  end
end
