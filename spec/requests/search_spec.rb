require "rails_helper"

RSpec.describe "Search", type: :request do
  it "scopes program and contract results to the signed in user" do
    user_a = User.create!(email: "search-a@example.com", password: "password")
    user_b = User.create!(email: "search-b@example.com", password: "password")

    program_a = Program.create!(name: "Alpha Program", user: user_a)
    program_b = Program.create!(name: "Beta Program", user: user_b)

    Contract.create!(
      program: program_a,
      contract_code: "ALPHA-100",
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 12, 31),
      sell_price_per_unit: 100
    )
    Contract.create!(
      program: program_b,
      contract_code: "BETA-200",
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 12, 31),
      sell_price_per_unit: 100
    )

    sign_in user_a

    get search_path(q: "Alpha")

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("Alpha Program")
    expect(response.body).not_to include("Beta Program")
    expect(response.body).to include("ALPHA-100")
    expect(response.body).not_to include("BETA-200")
  end
end
