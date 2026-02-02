require "rails_helper"

RSpec.describe "shared/ui/_input.html.erb", type: :view do
  it "renders cross platform search keytips" do
    render partial: "shared/ui/input", locals: { hotkey: "Ctrl K / ⌘ K", search_keytip: true }

    expect(rendered).to include("<kbd>Ctrl</kbd>")
    expect(rendered).to include("<kbd>⌘</kbd>")
    expect(rendered).to include("Ctrl K or Command K")
  end
end
