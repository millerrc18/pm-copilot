require "rails_helper"
require "securerandom"

RSpec.describe "Risk register", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "creates and edits a risk item and saves a view" do
    user = create_ui_user(suffix: "risk-#{SecureRandom.hex(4)}")
    program = Program.create!(name: "Risk Program", user: user)
    contract = Contract.create!(
      program: program,
      contract_code: "RSK-100",
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 12, 31),
      sell_price_per_unit: 120
    )

    sign_in_ui_user(email: user.email)

    visit risks_path
    within("header") do
      click_link "New item"
    end

    select "Risk", from: "Type"
    select "Open", from: "Status"
    fill_in "Title", with: "Late supplier delivery"
    fill_in "Description", with: "Supplier lead time is trending upward."
    select program.name, from: "Program scope"
    fill_in "Probability", with: 4
    fill_in "Impact", with: 3
    fill_in "Owner", with: "Alex"
    fill_in "Due date", with: "2024-03-10"
    click_button "Create risk item"

    expect(page).to have_content("Risk item created.")
    expect(page).to have_content("Late supplier delivery")
    expect(page).to have_content("Score 12")
    expect(page).to have_content("Risk exposure")

    click_link "Edit"
    select "Monitoring", from: "Status"
    select contract.contract_code, from: "Contract scope"
    click_button "Save changes"

    expect(page).to have_content("Risk item updated.")
    expect(page).to have_content("Monitoring")

    click_button "Save as default"
    expect(page).to have_content("Saved view applied.").or have_content("Saved view is ready to apply on your next visit.")
  end
end
