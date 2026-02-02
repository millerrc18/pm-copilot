require "rails_helper"

RSpec.describe "shared/ui/_input.html.erb", type: :view do
  it "renders cross platform search keytips" do
    render partial: "shared/ui/input", locals: { hotkey: "Ctrl K / ⌘ K", search_keytip: true }

    expect(rendered).to include("data-controller=\"os-detect\"")
    expect(rendered).to include("data-os-detect-target=\"mac\"")
    expect(rendered).to include("data-os-detect-target=\"nonMac\"")
    expect(rendered).to include("search-keytip hidden")
  end
end
