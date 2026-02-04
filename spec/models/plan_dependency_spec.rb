require "rails_helper"

RSpec.describe PlanDependency, type: :model do
  it "rejects circular dependencies" do
    user = User.create!(email: "plan-dep@example.com", password: "password")
    program = Program.create!(name: "Plan Program", user: user)
    first = PlanItem.create!(title: "First", item_type: "initiative", status: "planned", program: program)
    second = PlanItem.create!(title: "Second", item_type: "initiative", status: "planned", program: program)

    described_class.create!(predecessor: first, successor: second, dependency_type: "blocks")
    cycle = described_class.new(predecessor: second, successor: first, dependency_type: "blocks")

    expect(cycle).not_to be_valid
  end
end
