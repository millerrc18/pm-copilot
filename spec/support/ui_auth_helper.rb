module UiAuthHelper
  def ui_test_email(suffix = nil)
    base_email = ENV.fetch("UI_TEST_EMAIL")
    return base_email if suffix.nil?

    name, domain = base_email.split("@", 2)
    return base_email if domain.nil?

    "#{name}+#{suffix}@#{domain}"
  end

  def ui_test_password
    ENV.fetch("UI_TEST_PASSWORD")
  end

  def create_ui_user(suffix: nil, **attrs)
    User.create!({ email: ui_test_email(suffix), password: ui_test_password }.merge(attrs))
  end

  def sign_in_ui_user(email: ui_test_email, password: ui_test_password)
    visit new_user_session_path
    fill_in "Email", with: email
    fill_in "Password", with: password
    click_button "Sign in"
  end
end

RSpec.configure do |config|
  config.include UiAuthHelper, type: :system
end
