require "rails_helper"

RSpec.describe "Layout", type: :request do
  it "renders the favicon link tag" do
    get new_user_session_path

    expect(response).to have_http_status(:ok)
    document = Nokogiri::HTML(response.body)
    icon_link = document.at_css("link[rel='icon'][type='image/svg+xml']")

    expect(icon_link).not_to be_nil
    expect(icon_link["href"]).to include(".svg")
  end
end
