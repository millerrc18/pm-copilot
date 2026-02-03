require "rails_helper"
require "securerandom"

RSpec.describe "Sidebar navigation", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "routes to each primary section and updates active state" do
    user = create_ui_user(suffix: "nav-#{SecureRandom.hex(4)}")
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

    sign_in_ui_user(email: user.email)

    sections = [
      [ "Programs", "Dashboard", programs_path ],
      [ "Contracts", "Contracts", contracts_path ],
      [ "Milestones", "Milestones", delivery_milestones_path ],
      [ "Delivery units", "Delivery units", delivery_units_path ],
      [ "Risk & Opportunities", "Risk & Opportunities", risks_path ],
      [ "Cost Hub", "Cost Hub", cost_hub_path ],
      [ "Imports Hub", "Imports Hub", imports_hub_path ],
      [ "Planning Hub", "Planning Hub", planning_hub_path ],
      [ "Knowledge Center", "Knowledge Center", docs_path ]
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
    user = create_ui_user(suffix: "docs-#{SecureRandom.hex(4)}")
    Program.create!(name: "Docs Program", user: user)

    sign_in_ui_user(email: user.email)

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
      "Planning hub" => "timeline",
      "Proposals & bidding" => "New proposal",
      "Documentation hub" => "Create programs and contracts"
    }

    doc_titles.each do |title|
      visit docs_path
      within("main") do
        click_link title
      end
      expect(page).to have_css("h1", text: title)
      expect(page).to have_css(".docs-content")
      expectation = descriptive_expectations[title]
      expect(page).to have_content(expectation) if expectation
    end
  end

  it "shows proposal placeholders with a stub form" do
    user = create_ui_user(suffix: "proposal-#{SecureRandom.hex(4)}")
    Program.create!(name: "Proposal Program", user: user)

    sign_in_ui_user(email: user.email)

    visit proposals_path
    expect(page).to have_content("Active proposals")
    expect(page).to have_link("New proposal")

    click_link "New proposal"
    expect(page).to have_content("Proposal details")
    expect(page).to have_content("Draft sections")
  end
end
