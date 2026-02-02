require "rails_helper"

RSpec.describe "Cost Hub", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "shows totals and filters by program" do
    user = create_ui_user(suffix: "costhub")
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

    sign_in_ui_user(email: user.email)

    visit cost_hub_path(start_date: "2024-01-01", end_date: "2024-01-31")

    expect(page).to have_content("$185.00")
    expect(page).to have_content("Units delivered")
    expect(page).to have_content("3")
    expect(page).to have_css("canvas[data-controller='chart']", count: 2)

    select program_a.name, from: "Program"
    click_button "Apply filters"

    expect(page).to have_content("$125.00")
    expect(page).to have_content("2")

    expect(page).to have_css("tbody tr", count: 1)
  end

  it "persists the saved Cost Hub view filters" do
    user = create_ui_user(suffix: "costhub-save")
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

    sign_in_ui_user(email: user.email)

    visit cost_hub_path(start_date: "2024-01-01", end_date: "2024-01-31")
    select program_a.name, from: "Program"
    click_button "Apply filters"
    click_button "Save as default"

    visit cost_hub_path

    expect(find_field("Start date").value).to eq("2024-01-01")
    expect(find_field("End date").value).to eq("2024-01-31")
    expect(find_field("Program").value).to eq(program_a.id.to_s)
    expect(page).to have_content("$125.00")

    click_button "Reset saved view"

    visit cost_hub_path
    expect(find_field("Program").value).to eq("")
  end
end
