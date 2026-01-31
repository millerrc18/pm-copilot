require "rails_helper"

RSpec.describe CostEntry, type: :model do
  it "is valid with required fields" do
    entry = described_class.new(
      period_type: "week",
      period_start_date: Date.new(2024, 1, 1),
      material_cost: 100,
      other_costs: 25
    )

    expect(entry).to be_valid
  end

  it "rejects invalid period types" do
    entry = described_class.new(
      period_type: "quarter",
      period_start_date: Date.new(2024, 1, 1),
      material_cost: 100,
      other_costs: 0
    )

    expect(entry).not_to be_valid
    expect(entry.errors[:period_type]).not_to be_empty
  end

  it "requires non-negative numeric values" do
    entry = described_class.new(
      period_type: "month",
      period_start_date: Date.new(2024, 1, 1),
      hours_bam: -1,
      material_cost: 100,
      other_costs: 0
    )

    expect(entry).not_to be_valid
    expect(entry.errors[:hours_bam]).not_to be_empty
  end

  it "computes total costs" do
    entry = described_class.new(
      period_type: "week",
      period_start_date: Date.new(2024, 1, 1),
      hours_bam: 2,
      rate_bam: 50,
      material_cost: 100,
      other_costs: 25
    )

    expect(entry.total_labor_hours).to eq(2.to_d)
    expect(entry.total_labor_cost).to eq(100.to_d)
    expect(entry.total_cost).to eq(225.to_d)
  end
end
