require "rails_helper"

RSpec.describe Contract, type: :model do
  describe "#revenue_to_date" do
    it "sums contract period revenue through the as_of date" do
      user = User.create!(email: "test@example.com", password: "password")
      program = Program.create!(name: "Alpha", user: user)
      contract = Contract.create!(
        program: program,
        contract_code: "C-100",
        start_date: Date.new(2024, 1, 1),
        end_date: Date.new(2024, 12, 31),
        sell_price_per_unit: 100,
        planned_quantity: 10
      )

      ContractPeriod.create!(
        contract: contract,
        period_start_date: Date.new(2024, 1, 1),
        period_type: "monthly",
        units_delivered: 3,
        revenue_per_unit: 10
      )
      ContractPeriod.create!(
        contract: contract,
        period_start_date: Date.new(2024, 2, 1),
        period_type: "monthly",
        units_delivered: 2,
        revenue_per_unit: 20
      )
      ContractPeriod.create!(
        contract: contract,
        period_start_date: Date.new(2024, 3, 1),
        period_type: "monthly",
        units_delivered: 5,
        revenue_per_unit: 30
      )

      expect(contract.revenue_to_date(as_of: Date.new(2024, 2, 15))).to eq(BigDecimal("70"))
      expect(contract.total_revenue).to eq(BigDecimal("220"))
    end
  end
end
