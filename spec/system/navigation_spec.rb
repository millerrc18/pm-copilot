require "rails_helper"

RSpec.describe "Navigation", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "shows the Cost Hub link only for authenticated users" do
    visit new_user_session_path
    expect(page).to have_no_link("Cost Hub")

    user = create_ui_user(suffix: "nav")
    Program.create!(name: "Navigation Program", user: user)

    sign_in_ui_user(email: user.email)

    expect(page).to have_link("Cost Hub")
  end

  it "groups workspace and knowledge center links in the sidebar" do
    user = create_ui_user(suffix: "nav-groups")
    Program.create!(name: "Navigation Program", user: user)

    sign_in_ui_user(email: user.email)

    within("[data-testid='sidebar-group-workspace']") do
      expect(page).to have_link("Programs")
      expect(page).to have_link("Cost Hub")
      expect(page).to have_link("Contracts")
      expect(page).to have_link("Planning Hub")
      expect(page).to have_no_link("Imports Hub")
      expect(page).to have_no_link("Knowledge Center")
    end

    within("[data-testid='sidebar-group-imports']") do
      expect(page).to have_text("Imports")
      expect(page).to have_link("Imports Hub")
    end

    within("[data-testid='sidebar-group-registers']") do
      expect(page).to have_text("Registers")
      expect(page).to have_link("Milestones")
      expect(page).to have_link("Delivery units")
      expect(page).to have_link("Risk & Opportunities")
      expect(page).to have_no_link("Cost Hub")
    end

    within("[data-testid='sidebar-group-knowledge-center']") do
      expect(page).to have_text("Knowledge Center")
      expect(page).to have_link("Knowledge Center", href: docs_path)
    end
  end
end
