require "rails_helper"
require "securerandom"
require "base64"

RSpec.describe "Account management", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "allows signing out from the user menu" do
    user = create_ui_user(suffix: "menu")
    Program.create!(name: "Sign Out Program", user: user)

    sign_in_ui_user(email: user.email)

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

    email = ui_test_email("new-user-#{SecureRandom.hex(4)}")
    fill_in "Email", with: email
    fill_in "Password", with: ui_test_password
    fill_in "Password confirmation", with: ui_test_password
    click_button "Create account"

    expect(page).to have_current_path(root_path)
    expect(page).to have_content("Dashboard")
  end

  it "allows avatar uploads from the account page" do
    user = create_ui_user(suffix: "avatar")
    sign_in_ui_user(email: user.email)

    visit profile_path

    avatar = build_avatar_file
    attach_file "Avatar", avatar.path
    click_button "Upload avatar"

    expect(page).to have_content("Avatar updated.")
    expect(user.reload.avatar).to be_attached
  ensure
    avatar&.close
    avatar&.unlink
  end

  it "persists theme selection from the account page" do
    user = create_ui_user(suffix: "theme")
    sign_in_ui_user(email: user.email)

    visit profile_path
    find("label", text: "Dark blue").click
    click_button "Update theme"

    expect(page).to have_content("Appearance updated.")
    expect(user.reload.theme).to eq("dark-blue")

    visit programs_path
    expect(page).to have_css("html[data-theme='dark-blue']", visible: :all)
  end

  def build_avatar_file
    png_data = Base64.decode64(
      "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII="
    )
    file = Tempfile.new([ "avatar", ".png" ])
    file.binmode
    file.write(png_data)
    file.rewind
    file
  end
end
