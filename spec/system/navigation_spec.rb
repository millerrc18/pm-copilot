require "rails_helper"

RSpec.describe "Navigation", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "shows the Cost Hub link only for authenticated users" do
    visit new_user_session_path
    expect(page).to have_no_link("Cost Hub")

    user = User.create!(email: "nav@example.com", password: "password")
    Program.create!(name: "Navigation Program", user: user)

    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign in"

    expect(page).to have_link("Cost Hub")
  end

  it "groups workspace and knowledge center links in the sidebar" do
    user = User.create!(email: "nav-groups@example.com", password: "password")
    Program.create!(name: "Navigation Program", user: user)

    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign in"

    within("[data-testid='sidebar-group-workspace']") do
      expect(page).to have_link("Programs")
      expect(page).to have_link("Cost Hub")
      expect(page).to have_link("Contracts")
      expect(page).to have_no_link("Knowledge Center")
    end

    within("[data-testid='sidebar-group-imports']") do
      expect(page).to have_no_link("Cost Hub")
    end

    within("[data-testid='sidebar-group-knowledge-center']") do
      expect(page).to have_text("Knowledge Center")
      expect(page).to have_link("Knowledge Center", href: docs_path)
    end
  end
end
