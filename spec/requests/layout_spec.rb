require "rails_helper"

RSpec.describe "Layout", type: :request do
  it "renders the favicon link tag" do
    get new_user_session_path

    expect(response).to have_http_status(:ok)
    document = Nokogiri::HTML(response.body)
    icon_links = document.css("link[rel='icon'][type='image/png']")

    expect(icon_links).not_to be_empty
    expect(icon_links.map { |link| link["href"] }).to include(a_string_including("branding/black-favicon"))
  end
end
