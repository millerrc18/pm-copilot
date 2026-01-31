require "rails_helper"

RSpec.describe "Global registers", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "edits and deletes delivery units from the register" do
    user = User.create!(email: "units-register@example.com", password: "password")
    program = Program.create!(name: "Register Program", user: user)
    contract = Contract.create!(
      program: program,
      contract_code: "REG-001",
      start_date: Date.current.beginning_of_year,
      end_date: Date.current.end_of_year,
      sell_price_per_unit: 120,
      planned_quantity: 8
    )
    unit = DeliveryUnit.create!(contract: contract, unit_serial: "REG-UNIT-1", ship_date: Date.current, notes: "Initial")

    sign_in(user)

    visit delivery_units_path

    within("tr", text: unit.unit_serial) do
      click_link "Edit"
    end

    expect(page).to have_content("Edit delivered unit")
    fill_in "Notes", with: "Updated notes"
    click_button "Update unit"

    expect(page).to have_content("Delivered unit updated.")
    expect(page).to have_content("Updated notes")

    visit delivery_units_path

    within("tr", text: unit.unit_serial) do
      click_button "Delete"
    end

    expect(page).to have_content("Delivered unit deleted.")
    expect(page).to have_no_content(unit.unit_serial)
  end

  it "edits and deletes milestones from the register" do
    user = User.create!(email: "milestones-register@example.com", password: "password")
    program = Program.create!(name: "Milestone Register", user: user)
    contract = Contract.create!(
      program: program,
      contract_code: "REG-002",
      start_date: Date.current.beginning_of_year,
      end_date: Date.current.end_of_year,
      sell_price_per_unit: 180,
      planned_quantity: 15
    )
    milestone = DeliveryMilestone.create!(
      contract: contract,
      milestone_ref: "REG-MS-1",
      due_date: Date.current + 10,
      quantity_due: 3
    )

    sign_in(user)

    visit delivery_milestones_path

    within("tr", text: milestone.milestone_ref) do
      click_link "Edit"
    end

    expect(page).to have_content("Edit milestone")
    fill_in "Quantity due", with: "6"
    click_button "Update milestone"

    expect(page).to have_content("Milestone updated.")
    expect(page).to have_content("Qty due: 6")

    visit delivery_milestones_path

    within("tr", text: milestone.milestone_ref) do
      click_button "Delete"
    end

    expect(page).to have_content("Milestone deleted.")
    expect(page).to have_no_content(milestone.milestone_ref)
  end

  def sign_in(user)
    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign in"
  end
end
