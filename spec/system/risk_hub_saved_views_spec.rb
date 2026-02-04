require "rails_helper"
require "securerandom"

RSpec.describe "Risk hub saved views", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "persists a saved view and enforces program scoping" do
    user = create_ui_user(suffix: "risk-saved-#{SecureRandom.hex(4)}")
    program = Program.create!(name: "Primary Program", user: user)
    other_program = Program.create!(name: "Other Program", user: user)

    Risk.create!(
      title: "Primary risk",
      risk_type: "risk",
      probability: 3,
      impact: 4,
      status: "open",
      program: program
    )
    Risk.create!(
      title: "Other risk",
      risk_type: "risk",
      probability: 2,
      impact: 2,
      status: "open",
      program: other_program
    )

    sign_in_ui_user(email: user.email)
    visit risks_path(program_id: program.id)

    click_button "Save as default"
    expect(page).to have_content("Risks and Opportunities view saved as default.")

    visit risks_path
    expect(page).to have_content("Saved view applied.").or have_content("Saved view is ready to apply on your next visit.")
    expect(page).to have_content("Primary risk")
    expect(page).to have_no_content("Other risk")
  end

  it "prevents access to another user's program via query params" do
    user = create_ui_user(suffix: "risk-scope-#{SecureRandom.hex(4)}")
    program = Program.create!(name: "Scoped Program", user: user)
    other_user = create_ui_user(suffix: "risk-other-#{SecureRandom.hex(4)}")
    other_program = Program.create!(name: "Other User Program", user: other_user)

    Risk.create!(
      title: "Scoped risk",
      risk_type: "risk",
      probability: 3,
      impact: 3,
      status: "open",
      program: program
    )
    Risk.create!(
      title: "Other risk",
      risk_type: "risk",
      probability: 4,
      impact: 2,
      status: "open",
      program: other_program
    )

    sign_in_ui_user(email: user.email)
    visit risks_path(program_id: other_program.id)

    expect(page).to have_content("Scoped risk")
    expect(page).to have_no_content("Other risk")
  end
end
