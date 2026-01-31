require "rails_helper"

RSpec.describe "Cost Hub", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "shows totals and filters by program" do
    user = User.create!(email: "costhub@example.com", password: "password")
    program_a = Program.create!(name: "Atlas", user: user)
    program_b = Program.create!(name: "Borealis", user: user)

    CostEntry.create!(
      program: program_a,
      period_type: "week",
      period_start_date: Date.new(2024, 1, 5),
      material_cost: 100,
      other_costs: 25
    )
    CostEntry.create!(
      program: program_b,
      period_type: "week",
      period_start_date: Date.new(2024, 1, 8),
      material_cost: 50,
      other_costs: 10
    )

    contract_a = Contract.create!(
      program: program_a,
      contract_code: "A-100",
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 12, 31),
      sell_price_per_unit: 100,
      planned_quantity: 10
    )
    contract_b = Contract.create!(
      program: program_b,
      contract_code: "B-100",
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 12, 31),
      sell_price_per_unit: 100,
      planned_quantity: 10
    )

    DeliveryUnit.create!(contract: contract_a, unit_serial: "A-001", ship_date: Date.new(2024, 1, 10))
    DeliveryUnit.create!(contract: contract_a, unit_serial: "A-002", ship_date: Date.new(2024, 1, 11))
    DeliveryUnit.create!(contract: contract_b, unit_serial: "B-001", ship_date: Date.new(2024, 1, 12))

    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign in"

    visit cost_hub_path(start_date: "2024-01-01", end_date: "2024-01-31")

    expect(page).to have_content("$185.00")
    expect(page).to have_content("Units delivered")
    expect(page).to have_content("3")

    select program_a.name, from: "Program"
    click_button "Apply filters"

    expect(page).to have_content("$125.00")
    expect(page).to have_content("2")

    expect(page).to have_css("tbody tr", count: 1)
  end
end
