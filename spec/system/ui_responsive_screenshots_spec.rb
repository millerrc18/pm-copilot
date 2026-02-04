require "rails_helper"
require "securerandom"

RSpec.describe "Responsive UI screenshots", type: :system, js: true do
  include UiScreenshotHelper
  include ActiveSupport::Testing::TimeHelpers

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
    travel_to Date.new(2024, 6, 15) do
      user = create_ui_user(suffix: "ui-#{SecureRandom.hex(6)}")
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
      Contract.create!(
        program: program,
        contract_code: "AUR-2025",
        start_date: Date.new(2025, 1, 1),
        end_date: Date.new(2025, 12, 31),
        sell_price_per_unit: 110,
        planned_quantity: 18
      )
      Contract.create!(
        program: program,
        contract_code: "AUR-2023",
        start_date: Date.new(2023, 1, 1),
        end_date: Date.new(2023, 12, 31),
        sell_price_per_unit: 90,
        planned_quantity: 12
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
      Risk.create!(
        title: "Supplier delay",
        risk_type: "risk",
        probability: 4,
        impact: 3,
        status: "open",
        program: program,
        owner: "Jordan",
        due_date: Date.new(2024, 3, 10)
      )
      Risk.create!(
        title: "Scope expansion",
        risk_type: "opportunity",
        probability: 3,
        impact: 4,
        status: "open",
        program: program,
        owner: "Taylor",
        due_date: Date.new(2024, 4, 5)
      )
      plan_item = PlanItem.create!(
        title: "Launch roadmap",
        item_type: "initiative",
        status: "planned",
        start_on: Date.new(2024, 1, 1),
        due_on: Date.new(2024, 2, 15),
        program: program
      )
      dependency_item = PlanItem.create!(
        title: "Dependency task",
        item_type: "task",
        status: "planned",
        start_on: Date.new(2024, 1, 15),
        due_on: Date.new(2024, 2, 1),
        program: program
      )
      PlanDependency.create!(
        predecessor: plan_item,
        successor: dependency_item,
        dependency_type: "blocks"
      )

      auth_viewports = {
        "iphone" => [ 390, 844 ],
        "ipad" => [ 820, 1180 ],
        "desktop" => [ 1440, 900 ]
      }

      auth_viewports.each do |device_name, (width, height)|
        set_viewport(width, height)
        visit new_user_session_path
        save_named_screenshot("auth/sign_in", "#{device_name}.png")
        save_ui_screenshot("branding/auth_sign_in", device_name, "default")

        visit new_user_registration_path
        save_named_screenshot("auth/sign_up", "#{device_name}.png")
        save_ui_screenshot("branding/auth_sign_up", device_name, "default")
      end

      sign_in_ui_user(email: user.email)

      branding_viewports = {
        "iphone" => [ 390, 844 ],
        "ipad" => [ 820, 1180 ],
        "desktop" => [ 1440, 900 ]
      }

      branding_viewports.each do |device_name, (width, height)|
        set_viewport(width, height)
        visit programs_path

        if width < 768
          open_sidebar
          save_ui_screenshot("branding/sidebar", device_name, "open")
          close_sidebar
        else
          save_ui_screenshot("branding/sidebar", device_name, "closed")
        end
      end

      chart_viewports = {
        "iphone" => [ 390, 844 ],
        "desktop" => [ 1440, 900 ]
      }

      chart_viewports.each do |device_name, (width, height)|
        set_viewport(width, height)
        visit contract_path(contract)
        expect(page).to have_css("canvas[data-controller='chart']", count: 3)
        save_named_screenshot("charts/contracts_show", "#{device_name}.png")
      end

      visit imports_hub_path(tab: "costs")
      select program.name, from: "Program"
      attach_file "Excel file", Rails.root.join("spec/fixtures/files/costs_import.xlsx")
      click_button "Import costs"
      expect(page).to have_content("Costs imported")

      account_viewports = {
        "iphone" => [ 390, 844 ],
        "ipad" => [ 820, 1180 ],
        "desktop" => [ 1440, 900 ]
      }

      theme_variants = {
        "dark-coral" => "dark-coral",
        "dark-blue" => "dark-blue",
        "light" => "light"
      }

      theme_variants.each do |folder, theme_value|
        user.update!(theme: theme_value)

        account_viewports.each do |device_name, (width, height)|
          set_viewport(width, height)
          visit profile_path
          save_ui_screenshot("account/#{folder}", device_name, "closed")
        end
      end

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
      end

      cost_hub_viewports = {
        "iphone" => [ 390, 844 ],
        "ipad" => [ 820, 1180 ],
        "desktop" => [ 1440, 900 ]
      }

      cost_hub_viewports.each do |device_name, (width, height)|
        set_viewport(width, height)
        visit cost_hub_path(start_date: "2024-01-01", end_date: "2024-01-31")
        expect(page).to have_css("tbody tr", count: 2)
        save_ui_screenshot("cost_hub/default", device_name, "closed")

        if width < 768
          open_sidebar
          save_ui_screenshot("cost_hub/default", device_name, "open")
          close_sidebar
        end

        user.update!(
          cost_hub_saved_filters: {
            "start_date" => "2024-01-01",
            "end_date" => "2024-01-31",
            "program_id" => program.id
          }
        )
        visit cost_hub_path
        expect(page).to have_css("tbody tr", count: 2)
        save_ui_screenshot("cost_hub/saved_view_applied", device_name, "closed")

        if width < 768
          open_sidebar
          save_ui_screenshot("cost_hub/saved_view_applied", device_name, "open")
          close_sidebar
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
          "imports_hub" => imports_hub_path,
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
          "docs_documentation_hub" => doc_path("documentation-hub"),
          "planning_hub_index" => planning_hub_path,
          "risks_index" => risks_path
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
                expect(page).to have_link("Knowledge Center")
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

        contracts_viewports = {
          "iphone" => [ 390, 844 ],
          "ipad" => [ 820, 1180 ],
          "desktop" => [ 1440, 900 ]
        }

        contracts_viewports.each do |device_name, (width, height)|
          user.update!(contracts_view: nil, contracts_view_year: nil)
          set_viewport(width, height)
          visit contracts_path
          save_ui_screenshot("contracts/default_active_year", device_name, "closed")

          visit contracts_path(view: "active_next_year")
          save_ui_screenshot("contracts/filtered_next_year", device_name, "closed")

          visit contracts_path(view: "all")
          save_ui_screenshot("contracts/filtered_all", device_name, "closed")
        end

        cost_hub_viewports = {
          "iphone" => [ 390, 844 ],
          "ipad" => [ 820, 1180 ],
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

          visit imports_hub_path(tab: "costs")
          save_ui_screenshot("imports/costs", device_name, "closed")

          if width < 768
            open_sidebar
            save_ui_screenshot("imports/costs", device_name, "open")
            close_sidebar
          end

          visit imports_hub_path(tab: "milestones")
          save_ui_screenshot("imports/milestones", device_name, "closed")

          if width < 768
            open_sidebar
            save_ui_screenshot("imports/milestones", device_name, "open")
            close_sidebar
          end

          visit imports_hub_path(tab: "delivery_units")
          save_ui_screenshot("imports/delivery_units", device_name, "closed")

          if width < 768
            open_sidebar
            save_ui_screenshot("imports/delivery_units", device_name, "open")
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

        planning_viewports = {
          "iphone" => [ 390, 844 ],
          "ipad" => [ 820, 1180 ],
          "desktop" => [ 1440, 900 ]
        }

        planning_viewports.each do |device_name, (width, height)|
          set_viewport(width, height)
          visit planning_hub_path(program_id: program.id)
          save_ui_screenshot("planning_hub/timeline", device_name, "closed")

          if width < 768
            open_sidebar
            save_ui_screenshot("planning_hub/timeline", device_name, "open")
            close_sidebar
          end

          visit planning_hub_path(program_id: program.id, view: "dependencies")
          save_ui_screenshot("planning_hub/dependencies", device_name, "closed")

          if width < 768
            open_sidebar
            save_ui_screenshot("planning_hub/dependencies", device_name, "open")
            close_sidebar
          end

          visit planning_hub_path(program_id: program.id, edit_item_id: plan_item.id)
          save_ui_screenshot("planning_hub/item_drawer", device_name, "closed")
        end

        risk_viewports = {
          "iphone" => [ 390, 844 ],
          "ipad" => [ 820, 1180 ],
          "desktop" => [ 1440, 900 ]
        }

        risk_viewports.each do |device_name, (width, height)|
          set_viewport(width, height)
          visit risks_path(program_id: program.id)
          save_ui_screenshot("risks_opportunities/default", device_name, "closed")

          if width < 768
            open_sidebar
            save_ui_screenshot("risks_opportunities/default", device_name, "open")
            close_sidebar
          end

          visit risks_path(program_id: program.id, risk_type: "risk", status: "open")
          save_ui_screenshot("risks_opportunities/filters", device_name, "closed")

          visit risks_path(program_id: program.id)
          save_ui_screenshot("risks_opportunities/heatmap", device_name, "closed")

          visit new_risk_path
          save_ui_screenshot("risks_opportunities/new", device_name, "closed")
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
