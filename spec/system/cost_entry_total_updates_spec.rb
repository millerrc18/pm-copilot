require "rails_helper"

RSpec.describe "Cost entry totals", type: :system, js: true do
  before do
    driven_by(:cuprite)
  end

  it "updates the total cost as inputs change" do
    user = create_ui_user(suffix: "cost-total")
    program = Program.create!(name: "Atlas", user: user)

    sign_in_ui_user(email: user.email, password: ui_test_password)

    visit new_cost_entry_path
    select program.name, from: "Program"
    select "Week", from: "Period type"
    fill_in "Period start date", with: Date.current.strftime("%Y-%m-%d")

    fill_in "Hours BAM", with: "2"
    fill_in "Rate BAM", with: "50"
    fill_in "Material cost", with: "100"
    fill_in "Other costs", with: "25"

    expect(page).to have_selector("[data-testid='cost-total']", text: "$225.00")
  end
end
