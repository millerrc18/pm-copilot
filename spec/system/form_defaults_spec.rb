require "rails_helper"

RSpec.describe "Form defaults", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "renders blank fields for new contracts" do
    user = User.create!(email: "contract-defaults@example.com", password: "password")
    program = Program.create!(name: "Defaults Program", user: user)

    sign_in(user)

    visit new_program_contract_path(program)

    expect(find_field("Contract code").value).to be_nil
    expect(find_field("Fiscal year").value).to be_nil
    expect(find_field("Planned quantity").value).to be_nil
    expect(find_field("Sell price per unit").value).to be_nil
    expect(find_field("Contract start date").value).to be_nil
    expect(find_field("Contract end date").value).to be_nil
  end

  it "renders blank fields for new milestones and returns on cancel" do
    user = User.create!(email: "milestone-defaults@example.com", password: "password")
    program = Program.create!(name: "Milestone Defaults", user: user)
    contract = Contract.create!(
      program: program,
      contract_code: "MD-001",
      start_date: Date.current.beginning_of_year,
      end_date: Date.current.end_of_year,
      sell_price_per_unit: 150,
      planned_quantity: 10
    )

    sign_in(user)

    visit new_contract_delivery_milestone_path(contract)

    expect(find_field("Milestone reference").value).to be_nil
    expect(find_field("delivery_milestone[due_date(1i)]").value).to eq("")
    expect(find_field("delivery_milestone[due_date(2i)]").value).to eq("")
    expect(find_field("delivery_milestone[due_date(3i)]").value).to eq("")
    expect(find_field("Quantity due").value).to be_nil

    click_link "Cancel"

    expect(page).to have_current_path(contract_path(contract))
  end

  it "renders blank fields for new cost periods" do
    user = User.create!(email: "period-defaults@example.com", password: "password")
    program = Program.create!(name: "Period Defaults", user: user)
    contract = Contract.create!(
      program: program,
      contract_code: "PD-001",
      start_date: Date.current.beginning_of_year,
      end_date: Date.current.end_of_year,
      sell_price_per_unit: 200,
      planned_quantity: 12
    )

    sign_in(user)

    visit new_contract_contract_period_path(contract)

    expect(find_field("contract_period[period_start_date(1i)]").value).to eq("")
    expect(find_field("contract_period[period_start_date(2i)]").value).to eq("")
    expect(find_field("contract_period[period_start_date(3i)]").value).to eq("")
    expect(find_field("Units delivered").value).to be_nil
    expect(find_field("Hours BAM").value).to be_nil
    expect(find_field("Rate BAM").value).to be_nil
    expect(find_field("Hours ENG").value).to be_nil
    expect(find_field("Rate ENG").value).to be_nil
  end

  def sign_in(user)
    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign in"
  end
end
