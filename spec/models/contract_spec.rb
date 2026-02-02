require "rails_helper"

RSpec.describe Contract, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  describe "validations" do
    it "requires unique contract_code" do
      user = User.create!(email: "unique@example.com", password: "password")
      program = Program.create!(name: "Program", user: user)
      Contract.create!(
        program: program,
        contract_code: "C-100",
        start_date: Date.new(2024, 1, 1),
        end_date: Date.new(2024, 12, 31),
        sell_price_per_unit: 100,
        planned_quantity: 10
      )

      duplicate = Contract.new(
        program: program,
        contract_code: "C-100",
        start_date: Date.new(2024, 1, 1),
        end_date: Date.new(2024, 12, 31),
        sell_price_per_unit: 100,
        planned_quantity: 5
      )

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:contract_code]).to include("has already been taken")
    end
  end

  describe ".active_in_year" do
    it "returns contracts that overlap the provided year" do
      user = User.create!(email: "yearfilter@example.com", password: "password")
      program = Program.create!(name: "Filter Program", user: user)
      overlap_start = Contract.create!(
        program: program,
        contract_code: "OVERLAP-START",
        start_date: Date.new(2025, 11, 1),
        end_date: Date.new(2026, 2, 1),
        sell_price_per_unit: 100,
        planned_quantity: 10
      )
      overlap_end = Contract.create!(
        program: program,
        contract_code: "OVERLAP-END",
        start_date: Date.new(2026, 12, 31),
        end_date: Date.new(2027, 1, 10),
        sell_price_per_unit: 100,
        planned_quantity: 10
      )
      in_year = Contract.create!(
        program: program,
        contract_code: "IN-YEAR",
        start_date: Date.new(2026, 1, 1),
        end_date: Date.new(2026, 12, 31),
        sell_price_per_unit: 100,
        planned_quantity: 10
      )
      outside = Contract.create!(
        program: program,
        contract_code: "OUTSIDE",
        start_date: Date.new(2024, 1, 1),
        end_date: Date.new(2024, 12, 31),
        sell_price_per_unit: 100,
        planned_quantity: 10
      )

      expect(Contract.active_in_year(2026)).to contain_exactly(overlap_start, overlap_end, in_year)
      expect(Contract.active_in_year(2026)).not_to include(outside)
    end
  end

  describe ".active_this_year" do
    it "uses the current year and next year scopes" do
      travel_to Date.new(2026, 6, 1) do
        user = User.create!(email: "relative@example.com", password: "password")
        program = Program.create!(name: "Relative Program", user: user)
        current_year_contract = Contract.create!(
          program: program,
          contract_code: "CURRENT-2026",
          start_date: Date.new(2026, 1, 1),
          end_date: Date.new(2026, 12, 31),
          sell_price_per_unit: 100,
          planned_quantity: 10
        )
        next_year_contract = Contract.create!(
          program: program,
          contract_code: "NEXT-2027",
          start_date: Date.new(2027, 1, 1),
          end_date: Date.new(2027, 12, 31),
          sell_price_per_unit: 100,
          planned_quantity: 10
        )

        expect(Contract.active_this_year).to contain_exactly(current_year_contract)
        expect(Contract.active_next_year).to contain_exactly(next_year_contract)
      end
    end
  end

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
