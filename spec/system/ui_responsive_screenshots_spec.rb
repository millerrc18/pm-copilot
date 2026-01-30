require "rails_helper"
require "securerandom"

RSpec.describe "Responsive UI screenshots", type: :system, js: true do
  include UiScreenshotHelper

  before do
    driven_by(:headless_chrome)
  end

  it "captures screenshots across Apple viewports" do
    user = User.create!(email: "ui-#{SecureRandom.hex(6)}@example.com", password: "password")
    program = Program.create!(
      name: "Aurora",
      customer: "Lumen Labs",
      description: "AI-driven fulfillment pilot.",
      user: user
    )
    contract = Contract.create!(
      program: program,
      contract_code: "AUR-2024",
      start_date: Date.new(2024, 1, 1),
      end_date: Date.new(2024, 12, 31),
      sell_price_per_unit: 100,
      planned_quantity: 20
    )

    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Log in"

    pages = {
      "programs_index" => programs_path,
      "programs_show" => program_path(program),
      "contracts_show" => contract_path(contract),
      "imports_new" => new_contract_cost_import_path(contract),
      "docs_dashboard" => docs_path
    }

    pages.each do |page_name, path|
      APPLE_VIEWPORTS.each do |device_name, (width, height)|
        set_viewport(width, height)
        visit path
        expect(page).to have_css(".app-shell")

        if width < 768
          expect(page).to have_no_css(".sidebar.is-open")
          expect(sidebar_offscreen?).to be(true)
          assert_sidebar_nav_stacks_vertically!
          assert_sidebar_icon_bounds!
          save_ui_screenshot(page_name, device_name, "closed")

          open_sidebar
          expect(page).to have_css(".sidebar.is-open")
          expect(page).to have_css(".sidebar-backdrop.is-open")
          save_ui_screenshot(page_name, device_name, "open")

          close_sidebar
          expect(page).to have_no_css(".sidebar.is-open")
          expect(page).to have_no_css(".sidebar-backdrop.is-open")
        else
          save_ui_screenshot(page_name, device_name, "closed")
        end
      end
    end
  end

  def assert_sidebar_nav_stacks_vertically!
    rects = sidebar_nav_rects
    expect(rects).not_to be_nil
    expect(rects.dig("second", "top")).to be > rects.dig("first", "top")
  end

  def assert_sidebar_icon_bounds!
    rect = sidebar_icon_rect
    expect(rect).not_to be_nil
    expect(rect["width"]).to be <= 28
    expect(rect["height"]).to be <= 28
  end

  def open_sidebar
    find('button[aria-label="Open menu"]', visible: :all).click
  end

  def close_sidebar
    find(".sidebar-backdrop", visible: :all).click
  end

  def sidebar_nav_rects
    evaluate_script(<<~JS)
      (() => {
        const links = document.querySelectorAll(".sidebar .sidebar-nav .nav-pill");
        if (links.length < 2) return null;
        const first = links[0].getBoundingClientRect();
        const second = links[1].getBoundingClientRect();
        return {
          first: { top: first.top, left: first.left },
          second: { top: second.top, left: second.left }
        };
      })()
    JS
  end

  def sidebar_icon_rect
    evaluate_script(<<~JS)
      (() => {
        const icon = document.querySelector(".sidebar .nav-pill-icon svg");
        if (!icon) return null;
        const rect = icon.getBoundingClientRect();
        return { width: rect.width, height: rect.height };
      })()
    JS
  end

  def sidebar_offscreen?
    evaluate_script(<<~JS)
      (() => {
        const sidebar = document.querySelector(".sidebar");
        if (!sidebar) return false;
        return sidebar.getBoundingClientRect().right <= 0;
      })()
    JS
  end
end
