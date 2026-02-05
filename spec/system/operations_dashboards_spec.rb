require "rails_helper"

RSpec.describe "Operations dashboards", type: :system do
  include UiAuthHelper

  it "renders Operations dashboards with data" do
    user = create_ui_user(suffix: "ops-dash")
    program = Program.create!(name: "Ops Program", user: user)
    import = OpsImport.create!(program: program, imported_by: user, report_type: "materials", checksum: "abc123")

    OpsMaterial.create!(
      program: program,
      ops_import: import,
      part_number: "PN-1",
      supplier: "Acme",
      receipt_date: Date.new(2024, 1, 5),
      quantity_received: 5,
      unit_cost: 10,
      extended_cost: 50
    )
    OpsShopOrder.create!(
      program: program,
      ops_import: import,
      order_number: "SO-1",
      status: "In Progress",
      due_date: Date.new(2024, 1, 15),
      order_quantity: 10,
      completed_quantity: 4
    )
    OpsShopOrderOperation.create!(
      program: program,
      ops_import: import,
      order_number: "SO-1",
      operation_number: "10",
      status: "Started"
    )
    OpsHistoricalEfficiency.create!(
      program: program,
      ops_import: import,
      period_start: Date.new(2024, 1, 1),
      planned_hours: 8,
      actual_hours: 10,
      variance_hours: 2
    )
    OpsScrapRecord.create!(
      program: program,
      ops_import: import,
      scrap_date: Date.new(2024, 1, 4),
      part_number: "PN-1",
      scrap_quantity: 1,
      scrap_cost: 20
    )
    OpsMrbPartDetail.create!(
      program: program,
      ops_import: import,
      mrb_number: "MRB-1",
      status: "open",
      part_number: "PN-1",
      quantity: 1,
      unit_cost: 10,
      extended_cost: 10
    )
    OpsBomComponent.create!(
      program: program,
      ops_import: import,
      parent_part_number: "ASM-1",
      component_part_number: "COMP-1",
      level: 1,
      quantity_per: 2
    )

    sign_in_ui_user(email: user.email)

    visit operations_procurement_path(program_id: program.id)
    expect(page).to have_content("Procurement dashboard")

    visit operations_production_path(program_id: program.id)
    expect(page).to have_content("Production board")

    visit operations_efficiency_path(program_id: program.id)
    expect(page).to have_content("Efficiency dashboard")

    visit operations_quality_path(program_id: program.id)
    expect(page).to have_content("Quality dashboard")

    visit operations_bom_path(program_id: program.id)
    expect(page).to have_content("BOM explorer")
  end
end
