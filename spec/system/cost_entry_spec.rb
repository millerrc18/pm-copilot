require "rails_helper"

RSpec.describe "Cost entries", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "creates a cost entry and updates totals" do
    user = create_ui_user(suffix: "manual")
    program = Program.create!(name: "Atlas", user: user)
    contract = Contract.create!(
      program: program,
      contract_code: "AT-100",
      start_date: Date.current.beginning_of_year,
      end_date: Date.current.end_of_year,
      sell_price_per_unit: 100,
      planned_quantity: 10
    )
    DeliveryUnit.create!(contract: contract, unit_serial: "AT-001", ship_date: Date.current)
    DeliveryUnit.create!(contract: contract, unit_serial: "AT-002", ship_date: Date.current)

    sign_in(user)

    visit new_cost_entry_path
    select "Week", from: "Period type"
    fill_in "Period start date", with: Date.current
    select program.name, from: "Program"
    fill_in "Hours BAM", with: "2"
    fill_in "Rate BAM", with: "50"
    fill_in "Material cost", with: "100"
    fill_in "Other costs", with: "25"
    fill_in "Notes", with: "Manual entry"
    click_button "Create cost entry"

    expect(page).to have_content("Cost entry created.")
    expect(page).to have_content(program.name)
    expect(page).to have_content("$225.00")
    expect(page).to have_content("$112.50")
  end

  it "edits a cost entry and recalculates totals" do
    user = create_ui_user(suffix: "editor")
    program = Program.create!(name: "Borealis", user: user)
    contract = Contract.create!(
      program: program,
      contract_code: "BO-200",
      start_date: Date.current.beginning_of_year,
      end_date: Date.current.end_of_year,
      sell_price_per_unit: 100,
      planned_quantity: 10
    )
    DeliveryUnit.create!(contract: contract, unit_serial: "BO-001", ship_date: Date.current)

    entry = CostEntry.create!(
      program: program,
      period_type: "week",
      period_start_date: Date.current,
      hours_bam: 2,
      rate_bam: 50,
      material_cost: 100,
      other_costs: 0
    )

    sign_in(user)

    visit edit_cost_entry_path(entry)
    fill_in "Material cost", with: "200"
    click_button "Save changes"

    expect(page).to have_content("Cost entry updated.")
    expect(page).to have_content("$300.00")
  end

  it "deletes a cost entry from the Cost Hub" do
    user = create_ui_user(suffix: "deleter")
    program = Program.create!(name: "Cascade", user: user)
    contract = Contract.create!(
      program: program,
      contract_code: "CA-300",
      start_date: Date.current.beginning_of_year,
      end_date: Date.current.end_of_year,
      sell_price_per_unit: 100,
      planned_quantity: 10
    )
    DeliveryUnit.create!(contract: contract, unit_serial: "CA-001", ship_date: Date.current)

    entry = CostEntry.create!(
      program: program,
      period_type: "week",
      period_start_date: Date.current,
      material_cost: 50,
      other_costs: 10
    )

    sign_in(user)

    visit cost_hub_path
    expect(page).to have_content(entry.period_start_date.to_s)

    within("tr", text: entry.period_start_date.to_s) do
      click_button "Delete"
    end

    expect(page).to have_content("Cost entry deleted.")
    expect(page).to have_content("No cost entries match this range.")
  end

  it "duplicates a cost entry and updates totals" do
    user = create_ui_user(suffix: "duper")
    program = Program.create!(name: "Drift", user: user)

    entry = CostEntry.create!(
      program: program,
      period_type: "week",
      period_start_date: Date.current,
      material_cost: 100,
      other_costs: 10
    )

    sign_in(user)

    visit cost_hub_path
    within("tr", text: entry.period_start_date.to_s) do
      click_link "Duplicate"
    end

    expect(find_field("Material cost").value.to_f).to eq(100.0)
    expect(find_field("Other costs").value.to_f).to eq(10.0)

    click_button "Create cost entry"

    expect(page).to have_content("Cost entry created.")
    expect(page).to have_css("tbody tr", count: 2)
    expect(page).to have_content("$220.00")
  end

  def sign_in(user)
    sign_in_ui_user(email: user.email)
  end
end
