require "rails_helper"

RSpec.describe "Risks", type: :request do
  let(:user) { User.create!(email: "risks@example.com", password: "password") }
  let(:program) { Program.create!(name: "Alpha Program", user: user) }
  let(:contract) do
    Contract.create!(
      program: program,
      contract_code: "ALPHA-400",
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 12, 31),
      sell_price_per_unit: 100
    )
  end

  before { sign_in user, scope: :user }

  it "creates a risk item" do
    expect do
      post risks_path, params: {
        risk: {
          title: "Late supplier delivery",
          risk_type: "risk",
          status: "open",
          probability: 3,
          impact: 4,
          owner: "Ops",
          due_date: "2024-06-01",
          description: "Supplier lead times are shifting.",
          mitigation: "Add secondary supplier.",
          program_id: program.id,
          contract_id: contract.id
        }
      }
    end.to change(Risk, :count).by(1)

    expect(response).to redirect_to(risks_path)
  end

  it "filters risk items by type and status" do
    Risk.create!(
      title: "Risk A",
      risk_type: "risk",
      status: "open",
      probability: 2,
      impact: 3,
      program: program
    )
    Risk.create!(
      title: "Opportunity B",
      risk_type: "opportunity",
      status: "closed",
      probability: 4,
      impact: 2,
      program: program
    )

    get risks_path(program_id: program.id, risk_type: "risk", status: "open")

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Risk A")
    expect(response.body).not_to include("Opportunity B")
  end
end
