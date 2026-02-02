require "rails_helper"

RSpec.describe "Search keytips", type: :request do
  let(:user) { User.create!(email: "keytip-request@example.com", password: "password") }

  before do
    allow_any_instance_of(ActionView::Base)
      .to receive(:stylesheet_link_tag)
      .and_call_original
    allow_any_instance_of(ActionView::Base)
      .to receive(:stylesheet_link_tag)
      .with("tailwind", hash_including("data-turbo-track": "reload"))
      .and_return("")
    sign_in user
    Program.create!(name: "Keytip Program", user: user)
  end

  it "renders os specific keytip targets hidden by default" do
    get programs_path

    expect(response).to have_http_status(:ok)

    document = Nokogiri::HTML(response.body)
    controller = document.at_css("[data-controller='os-detect']")
    expect(controller).not_to be_nil

    mac_tip = document.at_css("[data-os-detect-target='mac']")
    non_mac_tip = document.at_css("[data-os-detect-target='nonMac']")
    expect(mac_tip).not_to be_nil
    expect(non_mac_tip).not_to be_nil
    expect(mac_tip["class"]).to include("hidden")
    expect(non_mac_tip["class"]).to include("hidden")
  end
end
