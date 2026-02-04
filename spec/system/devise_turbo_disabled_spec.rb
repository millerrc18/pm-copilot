require "rails_helper"

RSpec.describe "Devise Turbo settings", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "disables Turbo Drive on sign-in and sign-up forms" do
    visit new_user_session_path
    expect(page).to have_css("form[data-turbo='false']")

    visit new_user_registration_path
    expect(page).to have_css("form[data-turbo='false']")
  end
end
