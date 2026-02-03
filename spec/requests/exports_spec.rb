require "rails_helper"

RSpec.describe "Exports", type: :request do
  it "exports cost hub data as xlsx" do
    user = User.create!(email: "export-cost@example.com", password: "password")
    program = Program.create!(name: "Export Program", user: user)
    CostEntry.create!(
      program: program,
      period_type: "week",
      period_start_date: Date.new(2024, 1, 1),
      material_cost: 100,
      other_costs: 25
    )

    sign_in user

    get cost_hub_export_path(format: :xlsx, start_date: "2024-01-01", end_date: "2024-01-31")

    expect(response).to have_http_status(:ok)
    expect(response.content_type).to include("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
  end

  it "exports risk data as pdf" do
    user = User.create!(email: "export-risk@example.com", password: "password")
    program = Program.create!(name: "Risk Export Program", user: user)
    Risk.create!(
      title: "Supplier delay",
      risk_type: "risk",
      probability: 3,
      impact: 4,
      status: "open",
      program: program
    )

    sign_in user

    get risks_export_path(format: :pdf)

    expect(response).to have_http_status(:ok)
    expect(response.content_type).to include("application/pdf")
  end
end
