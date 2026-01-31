require "rails_helper"
require "securerandom"

RSpec.describe "Account management", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "allows signing out from the user menu" do
    user = User.create!(email: "menu@example.com", password: "password")
    Program.create!(name: "Sign Out Program", user: user)

    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign in"

    find("summary", text: user.email, visible: :all).click
    find_button("Sign out", visible: :all).click

    expect(page).to have_current_path(new_user_session_path)
    expect(page).to have_content("Signed out")

    visit programs_path
    expect(page).to have_current_path(new_user_session_path)
  end

  it "allows users to sign up from the sign-in page" do
    visit new_user_session_path
    within(".auth-links") do
      click_link "Sign up"
    end

    email = "new-user-#{SecureRandom.hex(4)}@example.com"
    fill_in "Email", with: email
    fill_in "Password", with: "password"
    fill_in "Password confirmation", with: "password"
    click_button "Create account"

    expect(page).to have_current_path(root_path)
    expect(page).to have_content("Dashboard")
  end
end
