require "rails_helper"

RSpec.describe ContractPeriod, type: :model do
  it "requires revenue_per_unit" do
    user = User.create!(email: "revenue@example.com", password: "password")
    program = Program.create!(name: "Beta", user: user)
    contract = Contract.create!(
      program: program,
      contract_code: "C-200",
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 12, 31),
      sell_price_per_unit: 100,
      planned_quantity: 10
    )

    period = ContractPeriod.new(
      contract: contract,
      period_start_date: Date.new(2024, 1, 1),
      period_type: "monthly",
      units_delivered: 1,
      revenue_per_unit: nil
    )

    expect(period).not_to be_valid
    expect(period.errors[:revenue_per_unit]).to be_present
  end
end
