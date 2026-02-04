require "rails_helper"

RSpec.describe PlanItem, type: :model do
  it "requires a program" do
    item = described_class.new(title: "Plan", item_type: "initiative", status: "planned")
    expect(item).not_to be_valid
  end

  it "validates date order" do
    user = User.create!(email: "plan-item@example.com", password: "password")
    program = Program.create!(name: "Plan Program", user: user)

    item = described_class.new(
      title: "Plan",
      item_type: "initiative",
      status: "planned",
      start_on: Date.new(2024, 2, 1),
      due_on: Date.new(2024, 1, 1),
      program: program
    )

    expect(item).not_to be_valid
  end
end
