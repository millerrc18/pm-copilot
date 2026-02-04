require "rails_helper"

RSpec.describe "Branding", type: :system do
  it "renders the brand logo on auth and navigation views" do
    user = create_ui_user(suffix: "branding-logo")

    visit new_user_session_path
    expect(page).to have_css("[data-testid='brand-logo'] img[src*='branding/']")

    sign_in_ui_user(email: user.email)
    visit programs_path
    expect(page).to have_css("[data-testid='brand-logo'] img[src*='branding/']")
  end

  it "includes favicon and apple touch icon links" do
    visit new_user_session_path

    expect(page).to have_css("head link[rel='icon'][href*='favicon']", visible: false)
    expect(page).to have_css("head link[rel='apple-touch-icon'][href*='favicon']", visible: false)
  end
end
