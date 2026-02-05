require "rails_helper"
require "csv"

RSpec.describe "Operations imports", type: :system do
  include UiAuthHelper

  def build_csv(headers, rows)
    file = Tempfile.new([ "ops-import", ".csv" ])
    file.write(CSV.generate do |csv|
      csv << headers
      rows.each { |row| csv << row }
    end)
    file.rewind
    file
  end

  it "imports a materials report" do
    user = create_ui_user(suffix: "ops-import")
    program = Program.create!(name: "Ops Program", user: user)
    sign_in_ui_user(email: user.email)

    file = build_csv(
      OpsImportService::TEMPLATE_HEADERS.fetch("materials"),
      [ [ "PN-1", "Bracket", "Acme", "Steel", "Buyer", "PO-1", "2024-01-01", "2024-01-03", "2024-01-05", 5, 5, 10, 50, 3 ] ]
    )

    visit ops_imports_path
    select program.name, from: "Program"
    select "Materials", from: "Report type"
    attach_file "Excel file", file.path
    click_button "Import report"

    expect(page).to have_content("Import complete")
    expect(page).to have_content("Materials")
  end
end
