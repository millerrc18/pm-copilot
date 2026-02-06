require "rails_helper"

RSpec.describe "Delivery milestones", type: :request do
  let(:user) { User.create!(email: "milestones@example.com", password: "password") }
  let(:program) { Program.create!(name: "Alpha Program", user: user) }
  let(:contract) do
    Contract.create!(
      program: program,
      contract_code: "ALPHA-300",
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 12, 31),
      sell_price_per_unit: 100
    )
  end

  before { sign_in user, scope: :user }

  it "creates a milestone with a valid due date" do
    expect do
      post contract_delivery_milestones_path(contract), params: {
        delivery_milestone: {
          milestone_ref: "FY25-JAN",
          due_date: "2024-01-15",
          quantity_due: 12
        }
      }
    end.to change(DeliveryMilestone, :count).by(1)

    expect(response).to redirect_to(contract_path(contract))
  end
end
