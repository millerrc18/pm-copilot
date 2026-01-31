require "rails_helper"
require "securerandom"

RSpec.describe "Responsive UI screenshots", type: :system, js: true do
  include UiScreenshotHelper

  before do
    skip "Chrome is not available for UI screenshots." unless browser_available?

    driven_by(:cuprite, options: {
      timeout: 120,
      process_timeout: 60,
      browser_path: ENV["FERRUM_BROWSER_PATH"],
      browser_options: {
        "disable-gpu" => nil,
        "no-sandbox" => nil,
        "disable-dev-shm-usage" => nil
      }
    })
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
    3.times do |index|
      DeliveryUnit.create!(
        contract: contract,
        unit_serial: "AUR-#{index + 1}",
        ship_date: Date.new(2024, 1, 10 + index)
      )
    end
    cost_entry = CostEntry.create!(
      program: program,
      period_type: "week",
      period_start_date: Date.new(2024, 1, 5),
      hours_bam: 2,
      rate_bam: 50,
      material_cost: 100,
      other_costs: 25
    )

    auth_viewports = {
      "iphone_15_pro" => [ 393, 852 ],
      "desktop" => [ 1440, 900 ]
    }

    auth_viewports.each do |device_name, (width, height)|
      set_viewport(width, height)
      visit new_user_session_path
      save_ui_screenshot("sign_in", device_name, "view")

      visit new_user_registration_path
      save_ui_screenshot("sign_up", device_name, "view")
    end

    visit new_user_session_path
    fill_in "Email", with: user.email
    fill_in "Password", with: "password"
    click_button "Sign in"

    visit new_cost_import_path
    select program.name, from: "Program (optional)"
    attach_file "Excel file", Rails.root.join("spec/fixtures/files/costs_import.xlsx")
    click_button "Import"
    expect(page).to have_content("Costs imported")

    user_menu_viewports = {
      "iphone_15_pro" => [ 393, 852 ],
      "desktop" => [ 1440, 900 ]
    }

    user_menu_viewports.each do |device_name, (width, height)|
      set_viewport(width, height)
      visit programs_path

      if width < 768
        open_sidebar
      end

      open_user_menu(user.email)
      save_ui_screenshot("user_menu", device_name, "open")
    end

    pages = {
      "programs_index" => programs_path,
      "programs_show" => program_path(program),
      "contracts_show" => contract_path(contract),
      "contracts_index" => contracts_path,
      "milestones_index" => delivery_milestones_path,
      "delivery_units_index" => delivery_units_path,
      "proposals_index" => proposals_path,
      "proposals_new" => new_proposal_path,
      "profile" => profile_path,
      "imports_new" => new_cost_import_path,
      "cost_hub" => cost_hub_path,
      "docs_dashboard" => docs_path,
      "docs_quick_start" => doc_path("quick-start"),
      "docs_program_templates" => doc_path("program-templates"),
      "docs_ai_summaries" => doc_path("ai-summaries"),
      "docs_risk_tracker" => doc_path("risk-tracker"),
      "docs_portfolio_analytics" => doc_path("portfolio-analytics"),
      "docs_integrations" => doc_path("integrations"),
      "docs_risk_opportunities" => doc_path("risk-opportunities"),
      "docs_planning_hub" => doc_path("planning-hub"),
      "docs_proposals" => doc_path("proposals"),
      "docs_documentation_hub" => doc_path("documentation-hub")
    }

    pages.each do |page_name, path|
      APPLE_VIEWPORTS.each do |device_name, (width, height)|
        set_viewport(width, height)
        visit path
        expect(page).to have_css(".sidebar")
        assert_sidebar_nav_stacks_vertically!
        assert_sidebar_icon_bounds!

        if width < 768
          expect(page).to have_css("nav[aria-label='Bottom navigation']")
          within("nav[aria-label='Bottom navigation']") do
            expect(page).to have_link("Programs")
            expect(page).to have_link("Cost Hub")
            expect(page).to have_link("Knowledge")
            expect(page).to have_no_link("Panel")
          end
          expect(sidebar_offscreen?).to be(true)
          save_ui_screenshot(page_name, device_name, "closed")

          open_sidebar
          expect(page).to have_css(".sidebar.translate-x-0")
          expect(page).to have_css("[data-sidebar-target='backdrop'].opacity-100")
          save_ui_screenshot(page_name, device_name, "open")

          close_sidebar
          expect(page).to have_css(".sidebar.-translate-x-full")
        else
          expect(page).to have_no_css("nav[aria-label='Bottom navigation']")
          expect(sidebar_offscreen?).to be(false)
          save_ui_screenshot(page_name, device_name, "closed")
        end
      end
    end

    cost_hub_viewports = {
      "iphone" => [ 393, 852 ],
      "ipad" => [ 834, 1194 ],
      "desktop" => [ 1440, 900 ]
    }

    cost_hub_viewports.each do |device_name, (width, height)|
      set_viewport(width, height)
      visit cost_hub_path(start_date: "2024-01-01", end_date: "2024-01-31")
      expect(page).to have_css("tbody tr", count: 2)
      save_ui_screenshot("cost_hub", device_name, "closed")

      if width < 768
        open_sidebar
        save_ui_screenshot("cost_hub", device_name, "open")
        close_sidebar
      end

      visit new_cost_import_path
      save_ui_screenshot("cost_imports", device_name, "closed")

      if width < 768
        open_sidebar
        save_ui_screenshot("cost_imports", device_name, "open")
        close_sidebar
      end

      visit new_cost_entry_path
      save_ui_screenshot("cost_entries_new", device_name, "closed")

      if width < 768
        open_sidebar
        save_ui_screenshot("cost_entries_new", device_name, "open")
        close_sidebar
      end

      visit edit_cost_entry_path(cost_entry)
      save_ui_screenshot("cost_entries_edit", device_name, "closed")

      if width < 768
        open_sidebar
        save_ui_screenshot("cost_entries_edit", device_name, "open")
        close_sidebar
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
    expect(rect["width"]).to be <= 24
    expect(rect["height"]).to be <= 24
  end

  def open_sidebar
    find('button[aria-label="Open menu"]', visible: :all).click
  end

  def open_user_menu(email)
    find("summary", text: email, visible: :all).click
  end

  def close_sidebar
    find("[data-sidebar-target='backdrop']", visible: :all).click
  end

  def sidebar_nav_rects
    evaluate_script(<<~JS)
      (() => {
        const links = document.querySelectorAll(".sidebar .sidebar-nav a");
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
        const icon = document.querySelector(".sidebar .sidebar-nav svg");
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

  def browser_available?
    return true if ENV["FERRUM_BROWSER_PATH"].present? && File.exist?(ENV["FERRUM_BROWSER_PATH"])

    %w[
      /usr/bin/google-chrome
      /usr/bin/google-chrome-stable
      /usr/bin/chromium
      /usr/bin/chromium-browser
    ].any? { |path| File.exist?(path) }
  end
end
