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
end
