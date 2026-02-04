require "rails_helper"
require "securerandom"

RSpec.describe "Program metrics", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "shows profit, ROS, and ROC" do
    user = create_ui_user(suffix: "program-metrics-#{SecureRandom.hex(4)}")
    program = Program.create!(name: "Metrics Program", user: user)
    contract = Contract.create!(
      program: program,
      contract_code: "MET-100",
      start_date: Date.current.beginning_of_year,
      end_date: Date.current.end_of_year,
      sell_price_per_unit: 100,
      planned_quantity: 10
    )
    ContractPeriod.create!(
      contract: contract,
      period_start_date: Date.current,
      period_type: "monthly",
      units_delivered: 2,
      revenue_per_unit: 100
    )
    CostEntry.create!(
      program: program,
      period_type: "month",
      period_start_date: Date.current,
      hours_bam: 1,
      rate_bam: 50,
      material_cost: 0,
      other_costs: 0
    )

    sign_in_ui_user(email: user.email)
    visit program_path(program)

    expect(page).to have_content("Profit to date")
    expect(page).to have_content("$150.00")
    expect(page).to have_content("Return on sales")
    expect(page).to have_content("75.0%")
    expect(page).to have_content("Return on cost")
    expect(page).to have_content("300.0%")
  end
end
