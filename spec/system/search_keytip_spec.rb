require "rails_helper"

RSpec.describe "Search keytips", type: :system, js: true do
  before do
    skip "Chrome is not available for keytip checks." unless browser_available?
  end

  it "shows command keytips on Mac" do
    set_platform(platform: "MacIntel", user_agent: mac_user_agent)

    user = User.create!(email: "keytip-mac@example.com", password: "password")
    Program.create!(name: "Keytip Program", user: user)

    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign in"

    visit programs_path

    expect(page).to have_css("[data-search-keytip]", text: "⌘ K")
  end

  it "shows control keytips on non-Mac platforms" do
    set_platform(platform: "Win32", user_agent: windows_user_agent)

    user = User.create!(email: "keytip-win@example.com", password: "password")
    Program.create!(name: "Keytip Program", user: user)

    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign in"

    visit programs_path

    expect(page).to have_css("[data-search-keytip]", text: "Ctrl K")
  end

  def set_platform(platform:, user_agent:)
    page.driver.browser.command(
      "Emulation.setUserAgentOverride",
      userAgent: user_agent,
      platform: platform
    )
  end

  def mac_user_agent
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 13_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
  end

  def windows_user_agent
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
  end

  def browser_available?
    return true if ENV["FERRUM_BROWSER_PATH"].present? && File.exist?(ENV["FERRUM_BROWSER_PATH"])

    %w[
      /usr/bin/google-chrome
      /usr/bin/google-chrome-stable
      /usr/bin/chromium
      /usr/bin/chromium-browser
    ].any? { |path| File.exist?(path) }
  end
end
