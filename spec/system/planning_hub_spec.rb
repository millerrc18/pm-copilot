require "rails_helper"
require "securerandom"

RSpec.describe "Planning Hub", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "shows timeline items and updates them from the modal form" do
    user = create_ui_user(suffix: "plan-#{SecureRandom.hex(4)}")
    program = Program.create!(name: "Planning Program", user: user)
    contract = Contract.create!(
      program: program,
      contract_code: "PLAN-200",
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 12, 31),
      sell_price_per_unit: 250
    )
    milestone = DeliveryMilestone.create!(
      contract: contract,
      milestone_ref: "MS-200",
      due_date: Date.new(2024, 2, 1),
      quantity_due: 4
    )
    DeliveryUnit.create!(
      contract: contract,
      unit_serial: "UNIT-200",
      ship_date: Date.new(2024, 1, 15)
    )

    sign_in_ui_user(email: user.email)
    visit planning_hub_path

    expect(page).to have_content("PLAN-200")
    expect(page).to have_content("MS-200")
    expect(page).to have_content("UNIT-200")

    within("[data-testid='planning-modal-contracts-#{contract.id}']", visible: :all) do
      fill_in "Planned quantity", with: 12
      click_button "Save changes"
    end

    expect(page).to have_current_path(planning_hub_path)
    expect(page).to have_content("Contract was successfully updated.")

    within("[data-testid='planning-modal-milestones-#{milestone.id}']", visible: :all) do
      fill_in "Quantity due", with: 8
      click_button "Save changes"
    end

    expect(page).to have_current_path(planning_hub_path)
    expect(page).to have_content("Milestone updated.")
  end
end
