require "rails_helper"
require "securerandom"

RSpec.describe "Sidebar navigation", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "routes to each primary section and updates active state" do
    user = User.create!(email: "nav-#{SecureRandom.hex(4)}@example.com", password: "password")
    program = Program.create!(name: "Navigation Program", user: user)
    contract = Contract.create!(
      program: program,
      contract_code: "NAV-001",
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 12, 31),
      sell_price_per_unit: 100,
      planned_quantity: 10
    )
    DeliveryMilestone.create!(contract: contract, milestone_ref: "MS-1", due_date: Date.new(2024, 2, 1), quantity_due: 5)
    DeliveryUnit.create!(contract: contract, unit_serial: "NAV-UNIT-1", ship_date: Date.new(2024, 1, 15))

    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign in"

    sections = [
      [ "Programs", "Dashboard", programs_path ],
      [ "Contracts", "Contracts", contracts_path ],
      [ "Milestones", "Milestones", delivery_milestones_path ],
      [ "Delivery units", "Delivery units", delivery_units_path ],
      [ "Cost Hub", "Cost Hub", cost_hub_path ],
      [ "Knowledge Center", "Documentation", docs_path ]
    ]

    sections.each do |label, heading, path|
      within ".sidebar" do
        click_link label
      end

      expect(page).to have_current_path(path)
      expect(page).to have_css("h1", text: heading)
      within ".sidebar" do
        expect(page).to have_css(".sidebar-nav a", text: label, class: /bg-accent-red/)
      end
    end
  end

  it "opens documentation cards for new product areas" do
    user = User.create!(email: "docs-#{SecureRandom.hex(4)}@example.com", password: "password")
    Program.create!(name: "Docs Program", user: user)

    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign in"

    doc_titles = [
      "Quick start",
      "Program templates",
      "AI summaries",
      "Risk tracker",
      "Portfolio analytics",
      "Integrations",
      "Risk & Opportunities",
      "Planning hub",
      "Proposals & bidding",
      "Documentation hub"
    ]

    descriptive_expectations = {
      "Risk & Opportunities" => "mitigation",
      "Planning hub" => "proposal schedules",
      "Proposals & bidding" => "New proposal",
      "Documentation hub" => "Create programs and contracts"
    }

    doc_titles.each do |title|
      visit docs_path
      click_link title
      expect(page).to have_css("h1", text: title)
      expect(page).to have_css(".docs-content")
      expectation = descriptive_expectations[title]
      expect(page).to have_content(expectation) if expectation
    end
  end

  it "shows proposal placeholders with a stub form" do
    user = User.create!(email: "proposal-#{SecureRandom.hex(4)}@example.com", password: "password")
    Program.create!(name: "Proposal Program", user: user)

    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign in"

    visit proposals_path
    expect(page).to have_content("Active proposals")
    expect(page).to have_link("New proposal")

    click_link "New proposal"
    expect(page).to have_content("Proposal details")
    expect(page).to have_content("Draft sections")
  end
end
