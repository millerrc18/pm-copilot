require "rails_helper"

RSpec.describe "Knowledge Center search", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "shows ranked results and empty state" do
    user = create_ui_user(suffix: "docs-search")
    Program.create!(name: "Docs Program", user: user)

    sign_in_ui_user(email: user.email)

    visit docs_path(q: "planning")
    expect(page).to have_content("Results for \"planning\"")
    expect(page).to have_link("Planning hub")

    visit docs_path(q: "doesnotexist")
    expect(page).to have_content("No docs matched that search")
  end
end
