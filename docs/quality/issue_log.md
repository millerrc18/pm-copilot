# Issue Log

This log tracks quality issues and their resolution status. Update entries with dates, evidence, and references.

## ISS-001 Cost Import program select readability

- Status: Done
- Date: 2025-09-21
- Notes: Updated dark theme classes on the program select and added a system spec to assert the class list.
- Evidence: spec/system/cost_hub_import_spec.rb, bin/ui-screenshots (pending due to missing Chrome).

## ISS-002 Program scoped costs

- Status: Done
- Date: 2025-09-21
- Notes: Require program on cost entries, scope summaries and queries by program, and backfill ambiguous entries.
- Evidence: spec/models/cost_entry_spec.rb, spec/system/cost_hub_spec.rb, spec/system/cost_entry_spec.rb.

## ISS-003 Manual cost entry and editing

- Status: Done
- Date: 2025-09-21
- Notes: Add duplicate action, ensure program required in the form, and validate CRUD flows.
- Evidence: spec/system/cost_entry_spec.rb.

## ISS-004 Navigation update

- Status: Done
- Date: 2025-09-21
- Notes: Move Cost Hub under Workspace and place Cost Imports under Imports.
- Evidence: spec/system/navigation_spec.rb and bin/ui-screenshots (pending due to missing Chrome).

## ISS-005 First pass visualizations

- Status: Done
- Date: 2025-09-21
- Notes: Add Chart.js powered charts to Cost Hub and Contract pages with program and period filters.
- Evidence: spec/system/cost_hub_spec.rb, spec/system/contract_charts_spec.rb, bin/ui-screenshots (pending due to missing Chrome).

## ISS-006 Imports Hub consolidation

- Status: Done
- Date: 2026-02-01
- Notes: Added the Imports Hub with program scoped cost, milestone, and delivery unit imports plus dynamic XLSX template downloads and row level validation feedback.
- Evidence: bundle exec rspec; bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/cost_hub_import_spec.rb spec/system/navigation_spec.rb spec/system/navigation_routes_spec.rb spec/system/account_management_spec.rb; Playwright screenshot browser:/tmp/codex_browser_invocations/3b002a5e598312fe/artifacts/artifacts/imports-hub-costs.png; bin/ui-screenshots (pending due to missing Chrome).

## ISS-007 Contracts default active year and saved views

- Status: Done
- Date: 2026-02-01
- Notes: Added year based contracts filtering, a saved view selector, and a default active year filter on the contracts index.
- Evidence: bundle exec rspec; bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/cost_hub_import_spec.rb spec/system/navigation_spec.rb spec/system/navigation_routes_spec.rb spec/system/account_management_spec.rb; browser screenshot browser:/tmp/codex_browser_invocations/36ed1ebb3756a3d0/artifacts/artifacts/contracts-index.png; bin/ui-screenshots (pending due to missing Chrome).
## ISS-007 Cost Hub saved view persistence

- Status: Done
- Date: 2026-02-01
- Notes: Persisted Cost Hub filters per user, added save and reset controls, and adjusted chart layout to avoid iPhone overflow.
- Evidence: bundle exec rspec; bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/cost_hub_import_spec.rb spec/system/navigation_spec.rb spec/system/navigation_routes_spec.rb spec/system/account_management_spec.rb; Playwright screenshot browser:/tmp/codex_browser_invocations/4d890c96fdf758fa/artifacts/artifacts/cost-hub-saved-view.png; bin/ui-screenshots (pending due to missing Chrome).

## ISS-008 Account page overhaul

- Status: Done
- Date: 2026-02-02
- Notes: Rebuilt the account page with avatar upload, lifetime stats, and a three theme selector with user persistence.
- Evidence: UI_TEST_EMAIL=test@example.com UI_TEST_PASSWORD=Password123! bundle exec rspec; UI_TEST_EMAIL=test@example.com UI_TEST_PASSWORD=Password123! bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/cost_hub_import_spec.rb spec/system/navigation_spec.rb spec/system/navigation_routes_spec.rb spec/system/account_management_spec.rb; bin/ui-screenshots (pending due to missing Chrome).
## ISS-006 Loading feedback, favicon, and keytips

- Status: Done
- Date: 2026-02-02
- Notes: Added favicon SVG, styled the Turbo progress bar, added a global loading overlay, and updated search keytips to show Ctrl and Command.
- Evidence: spec/requests/layout_spec.rb, spec/views/shared/ui/input_spec.rb, bundle exec rspec, browser sign-in screenshot, bin/ui-screenshots (pending due to missing Chrome).

## ISS-009 Sign in and sign up turbo handling

- Status: Done
- Date: 2026-02-03
- Notes: Ensured Devise treats turbo stream submissions as navigational so sign in and sign up redirect correctly.
- Evidence: bundle exec rspec spec/initializers/devise_spec.rb.

## ISS-010 OS specific search keytips

- Status: Done
- Date: 2026-02-03
- Notes: Added OS detection for search keytips so macOS and iPadOS show Command K, Windows and Linux show Control K, and touch only devices show none.
- Evidence: spec/requests/search_keytips_spec.rb; spec/system/search_keytip_spec.rb; bundle exec rspec (fails due to missing UI_TEST_EMAIL); bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/cost_hub_import_spec.rb spec/system/navigation_spec.rb spec/system/navigation_routes_spec.rb spec/system/account_management_spec.rb (fails due to missing UI_TEST_EMAIL); bin/ui-screenshots (Chrome not available); browser:/tmp/codex_browser_invocations/9670e816eb8a1339/artifacts/artifacts/os-keytip-programs.png.

## ISS-011 Account theme updates without refresh

- Status: Done
- Date: 2026-02-03
- Notes: Apply theme classes on the root element, target the theme form at the top frame, and add instant theme switching on the account page.
- Evidence: spec/requests/theme_preferences_spec.rb; spec/system/account_management_spec.rb; browser:/tmp/codex_browser_invocations/823a3fcf41050f9e/artifacts/tmp/screenshots/ui/account_theme/theme-dark-coral.png; browser:/tmp/codex_browser_invocations/823a3fcf41050f9e/artifacts/tmp/screenshots/ui/account_theme/theme-dark-blue.png; browser:/tmp/codex_browser_invocations/823a3fcf41050f9e/artifacts/tmp/screenshots/ui/account_theme/theme-light.png; bin/ui-screenshots (pending).

## ISS-012 Search results not scoped to the signed in user

- Status: Done
- Date: 2026-02-03
- Notes: Scope global search results to the signed in user for programs and contracts.
- Evidence: spec/requests/search_spec.rb.

## ISS-013 UI screenshots require Chrome

- Status: Blocked
- Date: 2026-02-03
- Notes: bin/ui-screenshots skipped because Chrome was not available in the environment.
- Evidence: bin/ui-screenshots output (pending).

## ISS-014 Render deploy fails to load prawn matrix dependency

- Status: Done
- Date: 2026-02-04
- Notes: Added matrix to the production bundle and upgraded prawn to ensure matrix is declared as a runtime dependency on Ruby 3.4.1.
- Evidence: bundle exec ruby -e "require 'prawn'; require 'matrix'; puts 'ok'"; bundle exec rails runner "puts 'boot ok'"; bundle exec rubocop; bundle exec brakeman; bundle exec bundler-audit check --update; bundle exec rspec; bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/cost_hub_import_spec.rb spec/system/navigation_spec.rb spec/system/navigation_routes_spec.rb spec/system/account_management_spec.rb; bin/ui-screenshots.

## ISS-015 Risk exposure metrics and program scoping

- Status: Done
- Date: 2026-02-05
- Notes: Require program scope for risks, allow optional contracts aligned to program, add exposure totals and net exposure metrics, and introduce program level exposure snapshots.
- Evidence: UI_TEST_EMAIL=test@example.com UI_TEST_PASSWORD=Password123! bundle exec rspec; UI_TEST_EMAIL=test@example.com UI_TEST_PASSWORD=Password123! bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/cost_hub_import_spec.rb spec/system/navigation_spec.rb spec/system/navigation_routes_spec.rb spec/system/account_management_spec.rb; browser:/tmp/codex_browser_invocations/73b419c198d48205/artifacts/artifacts/risks-exposure-summary.png; bin/ui-screenshots (pending Chrome).

## ISS-016 Risk hub UX refresh and saved views

- Status: Done
- Date: 2026-02-03
- Notes: Added program scoped filters, saved view actions, exposure tiles, trend charts, and heatmaps for Risks and Opportunities.
- Evidence: UI_TEST_EMAIL=test@example.com UI_TEST_PASSWORD=Password123! bundle exec rspec; browser:/tmp/codex_browser_invocations/f2a9fb5f847f4ea3/artifacts/artifacts/risks-hub.png; bin/ui-screenshots (pending Chrome).

## ISS-017 Planning Hub dependencies and saved views

- Status: Done
- Date: 2026-02-03
- Notes: Added plan items, dependencies, saved views, and refreshed Planning Hub timeline, list, and dependencies views.
- Evidence: UI_TEST_EMAIL=test@example.com UI_TEST_PASSWORD=Password123! bundle exec rspec; browser:/tmp/codex_browser_invocations/f2a9fb5f847f4ea3/artifacts/artifacts/planning-hub.png; bin/ui-screenshots (pending Chrome).

## ISS-018 Program metrics: Profit, ROS, ROC

- Status: Done
- Date: 2026-02-03
- Notes: Programs dashboard overview now includes Profit, Return on Sales, and Return on Cost metrics with zero denominator handling for ratios.
- Evidence: UI_TEST_EMAIL=test@example.com UI_TEST_PASSWORD=Password123! bundle exec rspec; browser:/tmp/codex_browser_invocations/61ee250103d76e2c/artifacts/artifacts/program-metrics.png; bin/ui-screenshots (pending Chrome).

## ISS-019 Devise auth Turbo fetch blocked by external redirects

- Status: Done
- Date: 2026-02-06
- Notes: Disabled Turbo Drive on Devise forms to avoid fetch failures when a network appliance redirects to an external block page.
- Evidence: bundle exec rubocop; bundle exec brakeman; bundle exec bundler-audit check --update; RAILS_ENV=test bin/rails db:prepare; RAILS_ENV=test bin/rails tailwindcss:build; UI_TEST_EMAIL=test@example.com UI_TEST_PASSWORD=Password123! bundle exec rspec (fails because Chrome is not available for Cuprite); UI_TEST_EMAIL=test@example.com UI_TEST_PASSWORD=Password123! bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/cost_hub_import_spec.rb spec/system/navigation_spec.rb spec/system/navigation_routes_spec.rb spec/system/account_management_spec.rb; bin/ui-screenshots (pending Chrome).

## ISS-020 Turbo progress bar deprecation warning

- Status: Done
- Date: 2026-02-06
- Notes: Replaced deprecated Turbo progress bar delay API with Turbo.config.drive.progressBarDelay.
- Evidence: bundle exec rubocop; bundle exec brakeman; bundle exec bundler-audit check --update; RAILS_ENV=test bin/rails db:prepare; RAILS_ENV=test bin/rails tailwindcss:build; UI_TEST_EMAIL=test@example.com UI_TEST_PASSWORD=Password123! bundle exec rspec (fails because Chrome is not available for Cuprite); UI_TEST_EMAIL=test@example.com UI_TEST_PASSWORD=Password123! bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/cost_hub_import_spec.rb spec/system/navigation_spec.rb spec/system/navigation_routes_spec.rb spec/system/account_management_spec.rb; bin/ui-screenshots (pending Chrome).

## ISS-021 Chart.js importmap missing @kurkle/color

- Status: Done
- Date: 2026-02-06
- Notes: Added Chart.js importmap pins and updated the chart controller to import from chart.js/auto so the @kurkle/color dependency resolves.
- Evidence: bundle exec rubocop; bundle exec brakeman; bundle exec bundler-audit check --update; RAILS_ENV=test bin/rails db:prepare; RAILS_ENV=test bin/rails tailwindcss:build; UI_TEST_EMAIL=test@example.com UI_TEST_PASSWORD=Password123! bundle exec rspec (fails because Chrome is not available for Cuprite); UI_TEST_EMAIL=test@example.com UI_TEST_PASSWORD=Password123! bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/cost_hub_import_spec.rb spec/system/navigation_spec.rb spec/system/navigation_routes_spec.rb spec/system/account_management_spec.rb; bin/ui-screenshots (pending Chrome).

## ISS-022 Apple touch icon size mismatch

- Status: Open
- Date: 2026-02-08
- Notes: Page area is layout head icons. Added apple touch icon link using the provided favicon, but the files are 1536 by 1024 so a dedicated 180 by 180 icon is still needed for correct sizing.
- Evidence: app/assets/images/branding/black-favicon.png and white-favicon.png dimensions checked via a PNG header script.

## ISS-023 Favicon media query support varies by browser

- Status: Open
- Date: 2026-02-08
- Notes: Page area is layout head icons. Added prefers-color-scheme favicon links, but some browsers ignore media queries for link rel icon so the fallback icon remains necessary.
- Evidence: Layout includes both media specific and fallback favicon link tags.

## ISS-024 Operations audit docs baseline

- Status: Done
- Date: 2026-02-05
- Notes: Added baseline IFS report mapping, UI system notes, and current pattern audit for Operations to guide upcoming imports and dashboards.
- Evidence: docs/operations/ifs_report_mappings.md, docs/operations/ui_system.md, docs/operations/current_patterns.md.

## ISS-025 Operations dashboards and imports baseline

- Status: Done
- Date: 2026-02-05
- Notes: Added Operations imports, dashboards, saved views, and normalized models for procurement, production, efficiency, quality, and BOM workflows.
- Evidence: spec/services/ops_import_service_spec.rb, spec/models/ops_models_spec.rb, spec/system/operations_imports_spec.rb, spec/system/operations_dashboards_spec.rb, spec/system/ui_responsive_screenshots_spec.rb.

## ISS-026 Operations procurement schema guard and empty state

- Status: Done
- Date: 2026-02-09
- Notes: Added schema guardrails, deploy checks, and friendly empty states for Operations Procurement when schema or data is missing.
- Evidence: bundle exec rspec spec/requests/operations_procurement_spec.rb; UI_TEST_EMAIL=test@example.com UI_TEST_PASSWORD=Password123! bin/ui-screenshots (pending, Chrome not available); Playwright screenshot attempt failed due to Chromium crash.

## ISS-027 Operations dashboards empty states and migration guard

- Status: Done
- Date: 2026-02-14
- Notes: Render empty states with an Operations Imports link on procurement, production, efficiency, quality, and BOM dashboards and only show the schema banner when migrations are pending.
- Evidence: bundle exec rspec spec/requests/operations_procurement_spec.rb; browser:/tmp/codex_browser_invocations/d5dd6e13f42f9ee8/artifacts/tmp/screenshots/manual/operations-empty.png.

## ISS-028 Contract period creation failures and date input UX

- Status: Done
- Date: 2026-02-14
- Notes: Replace multi select date input with a single date field, add error flash messaging, and render validation errors on failed creates.
- Evidence: bundle exec rspec spec/requests/contract_periods_spec.rb; browser:/tmp/codex_browser_invocations/d5dd6e13f42f9ee8/artifacts/tmp/screenshots/manual/period-success.png; browser:/tmp/codex_browser_invocations/d5dd6e13f42f9ee8/artifacts/tmp/screenshots/manual/period-failure.png.

## ISS-029 Delivery units ship date parsing and milestone due date input

- Status: Done
- Date: 2026-02-14
- Notes: Parse typed ship dates in delivery units, switch milestone due dates to a single date field, and surface validation errors on failure.
- Evidence: bundle exec rspec spec/requests/delivery_units_spec.rb spec/requests/delivery_milestones_spec.rb.

## ISS-030 Cost Hub visible inputs and live total

- Status: Done
- Date: 2026-02-14
- Notes: Add placeholders and help text for labor categories and show a live total cost calculation in the cost entry form.
- Evidence: browser:/tmp/codex_browser_invocations/d5dd6e13f42f9ee8/artifacts/tmp/screenshots/manual/cost-total-live.png.

## ISS-031 Risk register accessibility and fields

- Status: Done
- Date: 2026-02-14
- Notes: Add mitigation notes, align labels to risks and opportunities terminology, and add request coverage for register filters.
- Evidence: bundle exec rspec spec/requests/risks_spec.rb; browser:/tmp/codex_browser_invocations/d5dd6e13f42f9ee8/artifacts/tmp/screenshots/manual/risks-index.png.

## ISS-032 Flash messaging consistency for Turbo forms

- Status: Done
- Date: 2026-02-14
- Notes: Add a dedicated flash container and turbo stream flash updates for create and update failures.
- Evidence: bundle exec rspec; browser:/tmp/codex_browser_invocations/d5dd6e13f42f9ee8/artifacts/tmp/screenshots/manual/period-success.png; browser:/tmp/codex_browser_invocations/d5dd6e13f42f9ee8/artifacts/tmp/screenshots/manual/period-failure.png.

## ISS-033 Operations imports OOM protection

- Status: Done
- Date: 2026-02-07
- Notes: Move operations imports to a background job, stream XLSX reads, batch insert rows, and add file size guardrails with clearer errors.
- Evidence: bundle exec rubocop; bundle exec brakeman; bundle exec bundler-audit check --update; bundle exec rspec; bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/cost_hub_import_spec.rb spec/system/navigation_spec.rb spec/system/navigation_routes_spec.rb spec/system/account_management_spec.rb; bin/ui-screenshots.

## ISS-034 Operations import queue visibility and worker guidance

- Status: Done
- Date: 2026-02-07
- Notes: Persist job identifiers, add enqueue and job lifecycle logs, and add refresh controls and last updated timestamps for Operations imports. Document the Solid Queue worker setup for Render.
- Evidence: bundle exec rubocop; bundle exec brakeman; bundle exec bundler-audit check --update; bundle exec rspec (fails: ops_imports_spec job_id assertion, missing tailwind.css, missing Chrome); bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/cost_hub_import_spec.rb spec/system/navigation_spec.rb spec/system/navigation_routes_spec.rb spec/system/account_management_spec.rb (fails: missing tailwind.css); bin/ui-screenshots (pending, Chrome not available); browser:/tmp/codex_browser_invocations/b150e7c108c033dc/artifacts/artifacts/ops-imports.png.

## ISS-035 Operations imports flash toast and header duplication

- Status: Done
- Date: 2026-02-07
- Notes: Replace the in-flow flash banner with fixed toasts and remove duplicate Operations Imports heading so the topbar branding only appears once.
- Evidence: bundle exec rspec (fails: ops_imports job_id mismatch, Chrome not available); bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/cost_hub_import_spec.rb spec/system/navigation_spec.rb spec/system/navigation_routes_spec.rb spec/system/account_management_spec.rb; bin/ui-screenshots (pending, Chrome not available); browser:/tmp/codex_browser_invocations/2eb6a834e3da803d/artifacts/artifacts/ops-imports-flash.png.
