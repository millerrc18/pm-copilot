require "rails_helper"

RSpec.describe "Operations Procurement", type: :request do
  it "renders procurement dashboard for a program with no ops data" do
    user = User.create!(email: "ops-procurement@example.com", password: "password")
    program = Program.create!(name: "Ops Program", user: user)

    sign_in user, scope: :user

    get operations_procurement_path(program_id: program.id)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("No procurement records match the current filters.")
  end

  it "renders an empty state when the user has no programs" do
    user = User.create!(email: "ops-empty@example.com", password: "password")

    sign_in user, scope: :user

    get operations_procurement_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("You do not have any programs yet.")
  end

  it "returns 503 with a setup message when ops schema is missing" do
    user = User.create!(email: "ops-missing@example.com", password: "password")
    program = Program.create!(name: "Ops Program", user: user)

    sign_in user, scope: :user

    allow(OpsMaterial).to receive(:all).and_raise(ActiveRecord::StatementInvalid.new("ops_materials missing"))

    get operations_procurement_path(program_id: program.id)

    expect(response).to have_http_status(:service_unavailable)
    expect(response.body).to include("Operations is being set up")
  end
end
