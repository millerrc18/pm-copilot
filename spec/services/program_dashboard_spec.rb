require "rails_helper"

RSpec.describe ProgramDashboard, type: :service do
  it "rolls up revenue using contract period totals" do
    user = User.create!(email: "dashboard@example.com", password: "password")
    program = Program.create!(name: "Gamma", user: user)
    as_of = Date.new(2024, 2, 15)

    contract_one = Contract.create!(
      program: program,
      contract_code: "C-300",
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 12, 31),
      sell_price_per_unit: 500,
      planned_quantity: 10
    )
    ContractPeriod.create!(
      contract: contract_one,
      period_start_date: Date.new(2024, 1, 1),
      period_type: "monthly",
      units_delivered: 3,
      revenue_per_unit: 10
    )
    ContractPeriod.create!(
      contract: contract_one,
      period_start_date: Date.new(2024, 2, 1),
      period_type: "monthly",
      units_delivered: 2,
      revenue_per_unit: 20
    )
    ContractPeriod.create!(
      contract: contract_one,
      period_start_date: Date.new(2024, 3, 1),
      period_type: "monthly",
      units_delivered: 5,
      revenue_per_unit: 30
    )
    DeliveryUnit.create!(contract: contract_one, unit_serial: "A1", ship_date: Date.new(2024, 2, 1))
    DeliveryUnit.create!(contract: contract_one, unit_serial: "A2", ship_date: Date.new(2024, 2, 10))

    contract_two = Contract.create!(
      program: program,
      contract_code: "C-400",
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 12, 31),
      sell_price_per_unit: 999,
      planned_quantity: 5
    )
    ContractPeriod.create!(
      contract: contract_two,
      period_start_date: Date.new(2024, 2, 1),
      period_type: "monthly",
      units_delivered: 1,
      revenue_per_unit: 50
    )
    DeliveryUnit.create!(contract: contract_two, unit_serial: "B1", ship_date: Date.new(2024, 2, 5))

    result = described_class.new(program).call(as_of: as_of)
    contract_row = result[:contracts].find { |row| row[:id] == contract_one.id }

    expect(contract_row[:revenue_to_date]).to eq(BigDecimal("70"))
    expect(result[:totals][:revenue_to_date]).to eq(BigDecimal("120"))
  end
end
