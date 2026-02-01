require "rails_helper"
require "tempfile"

RSpec.describe "Imports Hub", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "imports milestones for contracts in the selected program" do
    user = create_ui_user(suffix: "milestone-import")
    program = Program.create!(name: "Milestone Program", user: user)
    contract = Contract.create!(
      program: program,
      contract_code: "MS-101",
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 12, 31),
      sell_price_per_unit: 120,
      planned_quantity: 6
    )

    sign_in_ui_user(email: user.email)
    visit imports_hub_path(tab: "milestones")
    select program.name, from: "Program"

    file = build_xlsx(
      MilestoneImportService::REQUIRED_HEADERS,
      [
        [
          contract.contract_code,
          "MS-1",
          "2024-02-01",
          5,
          "First delivery",
          "",
          "",
          ""
        ]
      ]
    )

    attach_file "Excel file", file.path
    click_button "Import milestones"

    expect(page).to have_content("Milestones imported")
    expect(page).to have_content("Import complete")
  end

  it "rejects milestone imports with unknown contract codes" do
    user = create_ui_user(suffix: "milestone-invalid")
    program = Program.create!(name: "Milestone Program", user: user)
    Contract.create!(
      program: program,
      contract_code: "MS-202",
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 12, 31),
      sell_price_per_unit: 120,
      planned_quantity: 6
    )

    sign_in_ui_user(email: user.email)
    visit imports_hub_path(tab: "milestones")
    select program.name, from: "Program"

    file = build_xlsx(
      MilestoneImportService::REQUIRED_HEADERS,
      [
        [
          "UNKNOWN",
          "MS-2",
          "2024-03-01",
          4,
          "",
          "",
          "",
          ""
        ]
      ]
    )

    attach_file "Excel file", file.path
    click_button "Import milestones"

    expect(page).to have_content("Import failed")
    expect(page).to have_content("contract_code 'UNKNOWN' not found")
  end

  it "imports delivery units for contracts in the selected program" do
    user = create_ui_user(suffix: "unit-import")
    program = Program.create!(name: "Delivery Program", user: user)
    contract = Contract.create!(
      program: program,
      contract_code: "DU-101",
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 12, 31),
      sell_price_per_unit: 80,
      planned_quantity: 10
    )

    sign_in_ui_user(email: user.email)
    visit imports_hub_path(tab: "delivery_units")
    select program.name, from: "Program"

    file = build_xlsx(
      DeliveryUnitImportService::REQUIRED_HEADERS,
      [
        [
          contract.contract_code,
          "DU-001",
          "2024-01-15",
          "Delivered"
        ]
      ]
    )

    attach_file "Excel file", file.path
    click_button "Import delivery units"

    expect(page).to have_content("Delivery units imported")
    expect(page).to have_content("Import complete")
  end

  it "rejects delivery unit imports without contract codes" do
    user = create_ui_user(suffix: "unit-invalid")
    program = Program.create!(name: "Delivery Program", user: user)
    Contract.create!(
      program: program,
      contract_code: "DU-202",
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 12, 31),
      sell_price_per_unit: 80,
      planned_quantity: 10
    )

    sign_in_ui_user(email: user.email)
    visit imports_hub_path(tab: "delivery_units")
    select program.name, from: "Program"

    file = build_xlsx(
      DeliveryUnitImportService::REQUIRED_HEADERS,
      [
        [
          "",
          "DU-002",
          "2024-01-16",
          ""
        ]
      ]
    )

    attach_file "Excel file", file.path
    click_button "Import delivery units"

    expect(page).to have_content("Import failed")
    expect(page).to have_content("contract_code is required")
  end

  def build_xlsx(headers, rows)
    file = Tempfile.new([ "import", ".xlsx" ])
    file.binmode
    file.write(ImportTemplateBuilder.build(headers, rows))
    file.close
    file
  end
end
