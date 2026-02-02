require "rails_helper"

RSpec.describe "Contracts saved views", type: :system do
  include ActiveSupport::Testing::TimeHelpers

  before do
    driven_by(:rack_test)
  end

  it "persists the selected view across sessions" do
    travel_to Date.new(2026, 6, 1) do
      user = create_ui_user(suffix: "contracts-view")
      program = Program.create!(name: "Apex", user: user)
      Contract.create!(
        program: program,
        contract_code: "CURRENT-2026",
        start_date: Date.new(2026, 1, 1),
        end_date: Date.new(2026, 12, 31),
        sell_price_per_unit: 100,
        planned_quantity: 10
      )
      Contract.create!(
        program: program,
        contract_code: "NEXT-2027",
        start_date: Date.new(2027, 1, 1),
        end_date: Date.new(2027, 12, 31),
        sell_price_per_unit: 120,
        planned_quantity: 8
      )
      Contract.create!(
        program: program,
        contract_code: "PAST-2025",
        start_date: Date.new(2025, 1, 1),
        end_date: Date.new(2025, 12, 31),
        sell_price_per_unit: 90,
        planned_quantity: 12
      )

      sign_in_ui_user(email: user.email)

      visit contracts_path
      expect(page).to have_content("CURRENT-2026")
      expect(page).to have_no_content("NEXT-2027")
      expect(page).to have_no_content("PAST-2025")

      select "Active in year", from: "View"
      fill_in "Year", with: "2027"
      click_button "Apply"

      expect(page).to have_content("NEXT-2027")
      expect(page).to have_no_content("CURRENT-2026")

      page.driver.submit :delete, destroy_user_session_path, {}
      sign_in_ui_user(email: user.email)

      visit contracts_path
      expect(page).to have_select("View", selected: "Active in year")
      expect(find_field("Year").value).to eq("2027")
      expect(page).to have_content("NEXT-2027")
      expect(page).to have_no_content("CURRENT-2026")
    end
  end
end
