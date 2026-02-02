require "rails_helper"

RSpec.describe "Theme preferences", type: :request do
  let(:user) { User.create!(email: "theme-request@example.com", password: "password", theme: "dark-blue") }

  before do
    sign_in user
  end

  it "renders the theme class on the account page root element" do
    get profile_path

    expect(response).to have_http_status(:ok)
    document = Nokogiri::HTML(response.body)
    html = document.at_css("html")

    expect(html["class"]).to include("theme-dark-blue")
  end

  it "targets the theme form at the top frame" do
    get profile_path

    document = Nokogiri::HTML(response.body)
    form = document.at_css("form[data-turbo-frame='_top'][action='#{theme_preference_path}']")

    expect(form).not_to be_nil
  end
end
