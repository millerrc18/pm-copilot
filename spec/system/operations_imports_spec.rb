require "rails_helper"
require "caxlsx"

RSpec.describe "Operations imports", type: :system do
  include UiAuthHelper

  def build_workbook(headers, rows)
    file = Tempfile.new([ "ops-import", ".xlsx" ])
    package = Axlsx::Package.new
    package.workbook.add_worksheet(name: "Sheet1") do |sheet|
      sheet.add_row(headers)
      rows.each { |row| sheet.add_row(row) }
    end
    package.serialize(file.path)
    file
  end

  it "imports a materials report" do
    user = create_ui_user(suffix: "ops-import")
    program = Program.create!(name: "Ops Program", user: user)
    sign_in_ui_user(email: user.email)

    file = build_workbook(
      OpsImportService::TEMPLATE_HEADERS.fetch("materials"),
      [ [ "PN-1", "Bracket", "Acme", "Steel", "Buyer", "PO-1", "2024-01-01", "2024-01-03", "2024-01-05", 5, 5, 10, 50, 3 ] ]
    )

    visit ops_imports_path
    select program.name, from: "Program"
    select "Materials", from: "Report type"
    attach_file "Excel file", file.path
    click_button "Import report"

    expect(page).to have_content("Import started")
    expect(page).to have_content("Materials")
  end
end
