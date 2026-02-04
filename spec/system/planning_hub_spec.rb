require "rails_helper"
require "securerandom"

RSpec.describe "Planning Hub", type: :system do
  before do
    driven_by(:rack_test)
  end

  it "creates plan items, saves a view, and manages dependencies" do
    user = create_ui_user(suffix: "plan-#{SecureRandom.hex(4)}")
    program = Program.create!(name: "Planning Program", user: user)

    sign_in_ui_user(email: user.email)
    visit planning_hub_path(program_id: program.id, new_item: true)

    within("dialog", visible: :all) do
      fill_in "Title", with: "Launch roadmap"
      select "Initiative", from: "Item type"
      select "Planned", from: "Status"
      fill_in "Start date", with: "2024-01-01"
      fill_in "Due date", with: "2024-02-01"
      fill_in "Percent complete", with: "10"
      click_button "Create item"
    end

    expect(page).to have_content("Plan item created.")
    expect(page).to have_content("Launch roadmap")

    PlanItem.create!(
      title: "Dependency item",
      item_type: "task",
      status: "planned",
      program: program
    )

    visit planning_hub_path(program_id: program.id, view: "dependencies")
    select "Launch roadmap", from: "Predecessor"
    select "Dependency item", from: "Successor"
    select "Blocks", from: "Type"
    click_button "Add dependency"

    expect(page).to have_content("Dependency added.")
    expect(page).to have_content("Launch roadmap → Dependency item")

    visit planning_hub_path(program_id: program.id)
    click_button "Save as default"
    expect(page).to have_content("Planning Hub view saved as default.")

    visit planning_hub_path
    expect(page).to have_content("Saved view applied.").or have_content("Saved view is ready to apply on your next visit.")
  end

  it "enforces program scoping" do
    user = create_ui_user(suffix: "plan-scope-#{SecureRandom.hex(4)}")
    program = Program.create!(name: "Scoped Program", user: user)
    other_user = create_ui_user(suffix: "plan-other-#{SecureRandom.hex(4)}")
    other_program = Program.create!(name: "Other Program", user: other_user)

    PlanItem.create!(title: "Scoped item", item_type: "initiative", status: "planned", program: program)
    PlanItem.create!(title: "Other item", item_type: "initiative", status: "planned", program: other_program)

    sign_in_ui_user(email: user.email)
    visit planning_hub_path(program_id: other_program.id)

    expect(page).to have_content("Scoped item")
    expect(page).to have_no_content("Other item")
  end
end
