require "rails_helper"

RSpec.describe "Contract periods", type: :request do
  let(:user) { User.create!(email: "periods@example.com", password: "password") }
  let(:program) { Program.create!(name: "Alpha Program", user: user) }
  let(:contract) do
    Contract.create!(
      program: program,
      contract_code: "ALPHA-100",
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 12, 31),
      sell_price_per_unit: 100
    )
  end

  before { sign_in user, scope: :user }

  it "creates a contract period with valid params" do
    expect do
      post contract_contract_periods_path(contract), params: {
        contract_period: {
          period_start_date: "2024-01-08",
          period_type: "week",
          units_delivered: 5,
          revenue_per_unit: 125,
          hours_bam: 2,
          rate_bam: 50,
          material_cost: 25,
          other_costs: 10
        }
      }
    end.to change(ContractPeriod, :count).by(1)

    expect(response).to redirect_to(contract_path(contract))
  end

  it "renders errors when required params are missing" do
    expect do
      post contract_contract_periods_path(contract), params: {
        contract_period: {
          period_start_date: "",
          period_type: "week",
          revenue_per_unit: ""
        }
      }
    end.not_to change(ContractPeriod, :count)

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response.body).to include("prohibited this record from being saved")
  end
end
