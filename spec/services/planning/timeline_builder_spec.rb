require "rails_helper"

RSpec.describe Planning::TimelineBuilder, type: :service do
  it "returns timeline items for programs" do
    user = User.create!(email: "plan-timeline@example.com", password: "password")
    program = Program.create!(name: "Planner", user: user)
    contract = Contract.create!(
      program: program,
      contract_code: "PLN-001",
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 12, 31),
      sell_price_per_unit: 100
    )
    DeliveryMilestone.create!(
      contract: contract,
      milestone_ref: "MS-1",
      due_date: Date.new(2024, 2, 1),
      quantity_due: 5
    )
    DeliveryUnit.create!(
      contract: contract,
      unit_serial: "UNIT-1",
      ship_date: Date.new(2024, 1, 15)
    )

    items = described_class.new(programs: Program.where(id: program.id)).call

    expect(items.map(&:kind)).to include("contracts", "milestones", "delivery_units")
    expect(items.map(&:title)).to include("PLN-001", "MS-1", "UNIT-1")
  end
end
