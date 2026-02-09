# PM-Copilot Improvement Log

This is a living document that tracks product improvements and refinements across iterations. It is meant to be updated continuously as issues are discovered, features are refined, and UX polish opportunities emerge.

## How to use this log

- Add new items as soon as they are discovered.
- Keep each item small and testable.
- Link each improvement to one or more issues in `docs/quality/issue_log.md` (or create the issue if it does not exist yet).
- When an improvement is implemented, note the PR, date, and what evidence exists (tests, screenshots).

## Status definitions

- **Proposed**: identified but not yet scheduled.
- **Planned**: selected for an upcoming iteration, has acceptance criteria.
- **In progress**: being implemented.
- **Blocked**: waiting on dependency or decision.
- **Done**: implemented and verified.

## Current priorities (Iteration 3)

1. Program-scoped costs: costs must never be shared across programs.
2. Cost workflow: users can create, edit, delete, and duplicate cost entries, not only import.
3. Navigation clarity: Cost Hub under Workspace; Imports retains import templates.
4. Visualizations: lightweight charts for Cost Hub and Contract pages.
5. UI polish: dark-theme readability on form controls (including the Cost Import program select).

## Improvements backlog

### IMP-001 Program-scoped costs

- **Status**: Done
- **Why**: Programs are the top-level boundary. Costs cannot be shared across programs.
- **Approach**:
  - Enforce `CostEntry belongs_to Program` with `program_id` required.
  - Ensure imports assign `program_id` to created cost entries.
  - Audit all aggregations and scoping to prevent cross-program mixing.
- **Acceptance criteria**:
  - Every cost entry belongs to exactly one program.
  - Cost Hub totals and charts never include costs from other programs.
  - Contract metrics, when showing cost, are explicitly program-scoped.
- **Evidence**:
  - Model specs for validation.
  - System spec that creates two programs and verifies costs never mix.
  - Screenshots of Cost Hub with program filtering from bin/ui-screenshots (pending due to missing Chrome).
  - PR: pending.

### IMP-002 Cost entry CRUD (manual entry, edit, delete, duplicate)

- **Status**: Done
- **Why**: Import-only cost entry blocks adoption and prevents correcting mistakes.
- **Approach**:
  - Add Cost Entries create/edit/delete UI.
  - Add duplicate action to prefill a new entry from an existing entry.
  - Ensure totals update immediately.
- **Acceptance criteria**:
  - User can create a cost entry from UI.
  - User can edit imported costs.
  - User can delete costs with confirmation.
  - User can duplicate a cost entry.
- **Evidence**:
  - System specs for create/edit/delete/duplicate.
  - Screenshots of new and edit forms from bin/ui-screenshots (pending due to missing Chrome).
  - PR: pending.

### IMP-003 Navigation and information architecture

- **Status**: Done
- **Why**: Cost Hub should be in Workspace; Imports should stay import-related.
- **Approach**:
  - Move Cost Hub link into Workspace group.
  - Keep Cost Import templates under Imports.
  - Rename Docs to Knowledge Center or Documentation and place outside Workspace.
- **Acceptance criteria**:
  - Sidebar grouping matches the intended structure across desktop, iPad, iPhone.
- **Evidence**:
  - Navigation system spec.
  - Sidebar screenshots in all viewports from bin/ui-screenshots (pending due to missing Chrome).
  - PR: pending.

### IMP-004 Cost Hub visualizations

- **Status**: Done
- **Why**: Tables are hard to scan. Visual summaries improve insight.
- **Approach**:
  - Add a small set of charts that respect program and date filters.
  - Limit to 2 to 3 charts maximum to avoid clutter.
- **Candidate charts**:
  - Total cost over time (line chart).
  - Cost composition over time (stacked bar).
  - Unit cost over time (line) when units exist in selected range.
- **Acceptance criteria**:
  - Charts render with seeded data.
  - Charts update when filters change.
- **Evidence**:
  - System spec asserting chart containers render.
  - Screenshots for each viewport from bin/ui-screenshots (pending due to missing Chrome).
  - PR: pending.

### IMP-005 Contract visualizations

- **Status**: Done
- **Why**: Contracts need quick signals: delivery trend, progress vs plan.
- **Candidate charts**:
  - Delivered units over time (bar or line).
  - Cumulative delivered vs planned quantity (burn-up).
- **Acceptance criteria**:
  - Charts render and respect the contract context.
- **Evidence**:
  - System spec with seeded deliveries.
  - Screenshots from bin/ui-screenshots (pending due to missing Chrome).
  - PR: pending.

### IMP-006 Dark-theme form control readability

- **Status**: Done
- **Why**: Some controls (notably select dropdowns) are unreadable in dark mode.
- **Approach**:
  - Standardize Tailwind classes for inputs and selects.
  - Ensure focus ring and hover states are consistent.
- **Acceptance criteria**:
  - All primary controls meet readable contrast in dark theme.
- **Evidence**:
  - Screenshots of forms from bin/ui-screenshots (pending due to missing Chrome).
  - PR: pending.

### IMP-007 Instant account theme switching

- **Status**: Done
- **Why**: Theme changes should apply immediately without a manual refresh and persist across navigation.
- **Approach**:
  - Apply a root theme class in the layout and update it on selection change.
  - Target the theme update form at the top frame so the full document refreshes.
  - Add a Stimulus controller for instant preview.
- **Acceptance criteria**:
  - Selecting a theme updates the UI immediately.
  - Navigating or reloading preserves the chosen theme.
- **Evidence**:
  - Request and system specs for theme class and persistence.
  - Screenshots captured after theme change in browser:/tmp/codex_browser_invocations/823a3fcf41050f9e/artifacts/tmp/screenshots/ui/account_theme/.
  - Issue: ISS-011.

### IMP-009 Unified Imports Hub

- **Status**: Done
- **Why**: Imports were scattered across multiple pages and required contract specific entry points.
- **Approach**:
  - Add a single Imports Hub with tabs for costs, milestones, and delivery units.
  - Generate XLSX templates dynamically and show row level validation feedback.
  - Scope milestone and unit imports to the selected program via contract codes.
- **Acceptance criteria**:
  - Imports Hub renders tabbed sections with program selection.
  - Template downloads return valid XLSX files with required headers.
  - Invalid rows are reported and no partial records are created.
- **Evidence**:
  - bundle exec rspec.
  - bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/cost_hub_import_spec.rb spec/system/navigation_spec.rb spec/system/navigation_routes_spec.rb spec/system/account_management_spec.rb.
  - Playwright screenshot browser:/tmp/codex_browser_invocations/3b002a5e598312fe/artifacts/artifacts/imports-hub-costs.png.
  - bin/ui-screenshots (pending due to missing Chrome).
  - PR: pending.

### IMP-010 Contracts saved views and active year default

- **Status**: Done
- **Why**: Contracts should default to the active year and let users save a preferred view for later visits.
- **Approach**:
  - Add active year scopes with overlap logic.
  - Add contracts index filter controls for active this year, next year, specific year, and all.
  - Persist the selected view per user.
- **Acceptance criteria**:
  - Contracts index defaults to active contracts in the current year.
  - Users can switch views and see the preference persist across sessions.
- **Evidence**:
  - bundle exec rspec.
  - bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/cost_hub_import_spec.rb spec/system/navigation_spec.rb spec/system/navigation_routes_spec.rb spec/system/account_management_spec.rb.
  - browser screenshot browser:/tmp/codex_browser_invocations/36ed1ebb3756a3d0/artifacts/artifacts/contracts-index.png.

### IMP-011 OS specific search keytips

- **Status**: Done
- **Why**: The search hint should match the user's platform and hide on touch only devices.
- **Approach**:
  - Add a Stimulus controller that detects Apple platforms and touch only devices.
  - Render mac and non mac keytips hidden by default and reveal the right hint.
- **Acceptance criteria**:
  - macOS and iPadOS show Command K only.
  - Windows and Linux show Control K only.
  - Touch only devices do not show keytips.
- **Evidence**:
  - spec/requests/search_keytips_spec.rb.
  - spec/system/search_keytip_spec.rb.
  - bundle exec rspec (fails due to missing UI_TEST_EMAIL).
  - bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/cost_hub_import_spec.rb spec/system/navigation_spec.rb spec/system/navigation_routes_spec.rb spec/system/account_management_spec.rb (fails due to missing UI_TEST_EMAIL).
  - bin/ui-screenshots (Chrome not available).
  - browser:/tmp/codex_browser_invocations/9670e816eb8a1339/artifacts/artifacts/os-keytip-programs.png.
  - PR: pending.

### IMP-010 Cost Hub saved views and chart polish

- **Status**: Done
- **Why**: Users need a default Cost Hub view and charts should stay readable on iPhone layouts.
- **Approach**:
  - Persist Cost Hub filters per user and apply them on load.
  - Add Save as default and Reset saved view controls.
  - Tighten chart layout spacing and legend sizing for small viewports.
- **Acceptance criteria**:
  - Saved filter selections apply automatically on the next visit.
  - Reset removes saved defaults and returns to standard date range.
  - Charts stay within panel bounds on iPhone layouts.
- **Evidence**:
  - System spec covering saved view persistence.
  - bundle exec rspec.
  - Playwright screenshot browser:/tmp/codex_browser_invocations/4d890c96fdf758fa/artifacts/artifacts/cost-hub-saved-view.png.
  - bin/ui-screenshots (pending due to missing Chrome).
  - PR: pending.

### IMP-011 Account profile overhaul

- **Status**: Done
- **Why**: The account page needed a dedicated profile view with stats, avatar, and a fixed theme selector.
- **Approach**:
  - Add Active Storage for avatar uploads and surface a profile summary panel.
  - Show lifetime stats for programs, contracts, cost entries, and total cost.
  - Replace palette settings with a three option theme selector that persists per user.
- **Acceptance criteria**:
  - Account page shows profile, avatar upload, lifetime stats, and theme cards.
  - Theme selection persists and updates the page theme.
  - Avatar uploads attach successfully in system tests.
- **Evidence**:
  - UI_TEST_EMAIL=test@example.com UI_TEST_PASSWORD=Password123! bundle exec rspec.
  - UI_TEST_EMAIL=test@example.com UI_TEST_PASSWORD=Password123! bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/cost_hub_import_spec.rb spec/system/navigation_spec.rb spec/system/navigation_routes_spec.rb spec/system/account_management_spec.rb.
  - bin/ui-screenshots (pending due to missing Chrome).
  - PR: pending.

### IMP-012 Authentication turbo navigation

- **Status**: Done
- **Why**: Turbo form submissions for Devise should redirect properly to avoid stalled sign in or sign up flows.
- **Approach**:
  - Add turbo stream to Devise navigational formats.
  - Cover the configuration with a spec.
- **Acceptance criteria**:
  - Devise navigational formats include turbo stream.
  - Sign in and sign up redirects behave as navigational requests.
- **Evidence**:
  - bundle exec rspec spec/initializers/devise_spec.rb.
  - PR: pending.

### IMP-013 Risk and opportunity register

- **Status**: Done
- **Date**: 2026-02-03
- **Why**: Teams need a structured place to log risks and opportunities with ownership and severity scoring.
- **Approach**:
  - Add a Risk model with scoring, status tracking, and program or contract scoping.
  - Add a register with filters, summary widgets, and program or contract summary panels.
  - Add export buttons for register snapshots.
- **Acceptance criteria**:
  - Users can create, edit, and delete risk items.
  - Severity score updates based on probability and impact.
  - Program and contract pages show risk summaries.
- **Evidence**:
  - spec/models/risk_spec.rb.
  - spec/system/risk_register_spec.rb.
  - PR: pending.

### IMP-014 Planning Hub timeline

- **Status**: Done
- **Date**: 2026-02-03
- **Why**: Planning workflows need a single view of contracts, milestones, and delivery units.
- **Approach**:
  - Build a timeline aggregator and render it in the Planning Hub.
  - Add modal edit forms with return navigation to the hub.
- **Acceptance criteria**:
  - Timeline items appear for contracts, milestones, and delivery units.
  - Edits from the Planning Hub persist and return to the hub.
- **Evidence**:
  - spec/services/planning/timeline_builder_spec.rb.
  - spec/system/planning_hub_spec.rb.
  - PR: pending.

### IMP-015 Visualization upgrades for Cost Hub and Contracts

- **Status**: Done
- **Date**: 2026-02-03
- **Why**: Additional charts improve insight and reporting.
- **Approach**:
  - Add cost composition and cost per unit trend charts in Cost Hub.
  - Add a cost vs revenue chart and summary export panel for contracts.
- **Acceptance criteria**:
  - Cost Hub shows four charts and correct data.
  - Contract page shows three charts and summary metrics.
- **Evidence**:
  - spec/system/cost_hub_spec.rb.
  - spec/system/contract_charts_spec.rb.
  - PR: pending.

### IMP-016 Knowledge Center search and IA refresh

- **Status**: Done
- **Date**: 2026-02-03
- **Why**: Documentation needed clearer categories and more relevant search results.
- **Approach**:
  - Normalize documentation categories and update key guides.
  - Rank search results by title, summary, and content matches.
  - Add contextual help links on hubs.
- **Acceptance criteria**:
  - Knowledge Center search returns ranked results.
  - Core pages include help links.
- **Evidence**:
  - spec/system/knowledge_center_search_spec.rb.
  - spec/requests/search_spec.rb.
  - PR: pending.

### IMP-017 Export and notification support

- **Status**: Done
- **Date**: 2026-02-03
- **Why**: Stakeholders need quick XLSX and PDF exports with notifications.
- **Approach**:
  - Add exporters for Cost Hub and risk register.
  - Send export notification emails via a job.
- **Acceptance criteria**:
  - Export endpoints return XLSX and PDF files.
  - Export notification job sends email.
- **Evidence**:
  - spec/requests/exports_spec.rb.
  - spec/jobs/export_notification_job_spec.rb.
  - spec/mailers/export_notification_mailer_spec.rb.
  - PR: pending.

### IMP-018 Prawn matrix dependency for Ruby 3.4 deploy

- **Status**: Done
- **Date**: 2026-02-04
- **Why**: Ruby 3.4 no longer guarantees matrix in the default stdlib set, which caused prawn to fail on boot.
- **Approach**:
  - Add matrix to the production bundle.
  - Upgrade prawn to a release that declares matrix as a runtime dependency.
- **Acceptance criteria**:
  - bundle exec ruby -e "require 'prawn'; require 'matrix'; puts 'ok'" succeeds.
  - Rails boots without matrix load errors.
- **Evidence**:
  - bundle exec ruby -e "require 'prawn'; require 'matrix'; puts 'ok'".
  - bundle exec rails runner "puts 'boot ok'".
  - Issue: ISS-014.

### IMP-007 Search keytips cross-platform

- **Status**: Done
- **Why**: Current hint is Mac-specific.
- **Approach**:
  - Show Ctrl K and Command K together with kbd styling.
- **Acceptance criteria**:
  - Hint is not misleading for Windows users.
- **Evidence**:
  - View spec covering the keytip markup.
  - Browser sign-in screenshot and bin/ui-screenshots (pending due to missing Chrome).
  - PR: pending.

### IMP-009 Global loading feedback and favicon polish

- **Status**: Done
- **Why**: Users need clearer navigation feedback and consistent branding.
- **Approach**:
  - Add a favicon SVG that wraps the PNG source.
  - Style the Turbo progress bar and add a global loading overlay tied to aria-busy.
- **Acceptance criteria**:
  - Layout includes the SVG favicon link tag.
  - Turbo progress bar is styled and visible during navigation delays.
  - Global loading overlay appears when aria-busy is true.
- **Evidence**:
  - Request spec covering the favicon link.
  - Browser sign-in screenshot and bin/ui-screenshots (pending due to missing Chrome).
  - PR: pending.

### IMP-008 Cost Hub period type filter

- **Status**: Proposed
- **Why**: Mixed weekly and monthly entries can make charts harder to read.
- **Approach**:
  - Add a period type filter to Cost Hub and align charts to the selected type.
  - Persist the selected type in the query string.
- **Acceptance criteria**:
  - Users can filter to week or month entries.
  - Charts and totals update with the filter.
- **Evidence required**:
  - System spec covering the new filter.
  - UI screenshots showing the filtered state.

### IMP-019 Risk exposure and net exposure metrics

- **Status**: Done
- **Date**: 2026-02-05
- **Why**: The R&O hub needs clear liability and asset totals to show net exposure trends.
- **Approach**:
  - Require program scoping for risks and ensure contracts align to the program.
  - Add exposure totals and net exposure metrics to summaries.
  - Add program level exposure snapshots for trend tracking.
- **Acceptance criteria**:
  - Risk and opportunity exposure totals are calculated from open items.
  - Net exposure shows opportunity totals minus risk totals.
  - Program level snapshots can be captured without duplication.
- **Evidence**:
  - UI_TEST_EMAIL=test@example.com UI_TEST_PASSWORD=Password123! bundle exec rspec.
  - UI_TEST_EMAIL=test@example.com UI_TEST_PASSWORD=Password123! bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/cost_hub_import_spec.rb spec/system/navigation_spec.rb spec/system/navigation_routes_spec.rb spec/system/account_management_spec.rb.
  - browser:/tmp/codex_browser_invocations/73b419c198d48205/artifacts/artifacts/risks-exposure-summary.png.
  - bin/ui-screenshots (pending Chrome).

### IMP-020 Risk hub experience upgrade

- **Status**: Done
- **Date**: 2026-02-03
- **Why**: The R&O hub needed richer insights, saved views, and visual summaries for exposure trends.
- **Approach**:
  - Add program scoped filters with saved views and date range controls.
  - Add exposure tiles, burndown, opportunity trend, net exposure trend, and heatmaps.
- **Acceptance criteria**:
  - Filters and saved views persist for the user.
  - Charts render for the selected program.
  - Heatmaps show probability and impact distribution.
- **Evidence**:
  - UI_TEST_EMAIL=test@example.com UI_TEST_PASSWORD=Password123! bundle exec rspec.
  - browser:/tmp/codex_browser_invocations/f2a9fb5f847f4ea3/artifacts/artifacts/risks-hub.png.
  - bin/ui-screenshots (pending Chrome).

### IMP-021 Planning Hub model and UX foundation

- **Status**: Done
- **Date**: 2026-02-03
- **Why**: Planning Hub needed structured plan items, dependencies, and saved views for day to day planning.
- **Approach**:
  - Add plan items and dependencies with program scoping.
  - Provide timeline, list, and dependencies views with saved view actions.
- **Acceptance criteria**:
  - Users can create plan items and dependencies.
  - Saved views persist across visits.
- **Evidence**:
  - UI_TEST_EMAIL=test@example.com UI_TEST_PASSWORD=Password123! bundle exec rspec.
  - browser:/tmp/codex_browser_invocations/f2a9fb5f847f4ea3/artifacts/artifacts/planning-hub.png.
  - bin/ui-screenshots (pending Chrome).

### IMP-022 Program Profit, ROS, and ROC metrics

- **Status**: Done
- **Date**: 2026-02-03
- **Why**: Program dashboards needed profit and ratio metrics for quick performance checks.
- **Approach**:
  - Add Profit, Return on Sales, and Return on Cost to the program dashboard totals.
  - Display N/A when revenue or cost is zero and add tooltip definitions.
- **Acceptance criteria**:
  - Profit shows revenue minus cost.
  - ROS and ROC show percentages or N/A when denominators are zero.
- **Evidence**:
  - UI_TEST_EMAIL=test@example.com UI_TEST_PASSWORD=Password123! bundle exec rspec.
  - browser:/tmp/codex_browser_invocations/61ee250103d76e2c/artifacts/artifacts/program-metrics.png.
  - bin/ui-screenshots (pending Chrome).

### IMP-023 Auth Turbo mitigation and Chart.js importmap stability

- **Status**: Done
- **Date**: 2026-02-06
- **Why**: Auth forms and charts needed resilient behavior across network filters and importmap module resolution.
- **Approach**:
  - Disable Turbo Drive on Devise forms to avoid fetch failures on external redirect block pages.
  - Update Turbo progress bar configuration and pin Chart.js dependencies in importmap.
  - Add system coverage and update screenshot automation targets for auth and chart pages.
- **Acceptance criteria**:
  - Devise auth forms render with data-turbo disabled.
  - Chart pages render without module resolution errors for @kurkle/color.
- **Evidence**:
  - bundle exec rubocop.
  - bundle exec brakeman.
  - bundle exec bundler-audit check --update.
  - RAILS_ENV=test bin/rails db:prepare.
  - RAILS_ENV=test bin/rails tailwindcss:build.
  - UI_TEST_EMAIL=test@example.com UI_TEST_PASSWORD=Password123! bundle exec rspec (fails because Chrome is not available for Cuprite).
  - UI_TEST_EMAIL=test@example.com UI_TEST_PASSWORD=Password123! bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/cost_hub_import_spec.rb spec/system/navigation_spec.rb spec/system/navigation_routes_spec.rb spec/system/account_management_spec.rb.
  - bin/ui-screenshots (pending Chrome).

### IMP-024 Branding logos and favicons

- **Status**: Done
- **Date**: 2026-02-08
- **Why**: Branding needed to show the new logos and favicon variants across navigation and auth experiences.
- **Approach**:
  - Add a shared brand logo partial that toggles by theme.
  - Use the logo in sidebar, top bar, and Devise auth pages.
  - Add light and dark favicon link tags plus an apple touch icon link.
  - Add system coverage and branding screenshots under tmp/screenshots/ui/branding.
- **Acceptance criteria**:
  - Navigation and auth pages render the new logo for light and dark themes.
  - The head includes favicon and apple touch icon links.
- **Evidence**:
  - spec/system/branding_spec.rb.
  - bundle exec rubocop.
  - bundle exec brakeman.
  - bundle exec bundler-audit check --update.
  - UI_TEST_EMAIL=test@example.com UI_TEST_PASSWORD=Password123! bundle exec rspec (fails because Chrome is not available for Cuprite).
  - UI_TEST_EMAIL=test@example.com UI_TEST_PASSWORD=Password123! bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/cost_hub_import_spec.rb spec/system/navigation_spec.rb spec/system/navigation_routes_spec.rb spec/system/account_management_spec.rb.
  - bin/ui-screenshots (pending Chrome).
  - Playwright screenshot browser:/tmp/codex_browser_invocations/7f43d50eacbf07d5/artifacts/artifacts/branding-sign-in.png.
  - PR: pending.

## Completed improvements

- IMP-001 Program scoped costs. Evidence in system and model specs, screenshots pending due to missing Chrome.
- IMP-002 Cost entry CRUD. Evidence in system specs, screenshots pending due to missing Chrome.
- IMP-003 Navigation information architecture. Evidence in navigation specs, screenshots pending due to missing Chrome.
- IMP-004 Cost Hub visualizations. Evidence in cost hub system spec, screenshots pending due to missing Chrome.
- IMP-005 Contract visualizations. Evidence in contract charts system spec, screenshots pending due to missing Chrome.
- IMP-006 Dark theme form control readability. Evidence in cost import system spec, screenshots pending due to missing Chrome.
- IMP-009 Unified Imports Hub. Evidence in request and system specs, screenshots pending due to missing Chrome.
- IMP-010 Contracts saved views and active year default. Evidence in contracts system spec, screenshots pending due to missing Chrome.
- IMP-010 Cost Hub saved views and chart polish. Evidence in system specs, screenshots pending due to missing Chrome.
- IMP-007 Search keytips cross-platform. Evidence in view spec, screenshots pending due to missing Chrome.
- IMP-009 Global loading feedback and favicon polish. Evidence in request spec, screenshots pending due to missing Chrome.

### IMP-025 Operations audit and UI system baselines

- **Status**: Done
- **Date**: 2026-02-05
- **Why**: Operations work needs a shared baseline for report mappings, UI patterns, and existing repo conventions.
- **Approach**:
  - Document expected IFS report tabs with keys, measures, and filters.
  - Capture the shared Operations UI system expectations.
  - Summarize current import, saved view, chart, and table patterns.
- **Acceptance criteria**:
  - Mapping doc is available for the iteration.
  - UI system doc defines filter, card, chart, and table behavior.
  - Current pattern audit is captured for reuse.
- **Evidence**:
  - docs/operations/ifs_report_mappings.md.
  - docs/operations/ui_system.md.
  - docs/operations/current_patterns.md.
  - Issue: ISS-024.

### IMP-026 Operations imports and dashboards

- **Status**: Done
- **Date**: 2026-02-05
- **Why**: Operations intelligence requires standardized imports and dashboards for procurement, production, efficiency, quality, and BOM analysis.
- **Approach**:
  - Add OpsImport tracking with normalized tables for each report type.
  - Build dashboards with filters, summary cards, charts, and tables.
  - Add saved views per Operations page and new Knowledge Center docs.
- **Acceptance criteria**:
  - Operations imports accept IFS exports and record history.
  - Procurement, production, efficiency, quality, and BOM dashboards render for a selected program.
  - Saved views persist and apply per dashboard.
- **Evidence**:
  - spec/services/ops_import_service_spec.rb.
  - spec/models/ops_models_spec.rb.
  - spec/system/operations_imports_spec.rb.
  - spec/system/operations_dashboards_spec.rb.
  - docs/operations_overview.md and related Operations docs.
  - Issue: ISS-025.

### IMP-027 Operations procurement schema guardrails

- **Status**: Done
- **Date**: 2026-02-09
- **Why**: Operations Procurement needs a safe fallback when migrations are missing and a clear empty state for new users.
- **Approach**:
  - Add schema checks and deploy guards to ensure ops tables and saved filters are available.
  - Render a friendly setup message when schema is missing.
  - Show empty states when no programs or no procurement data exists.
- **Acceptance criteria**:
  - Procurement loads with no ops data and shows guidance text.
  - Missing schema returns a 503 with a setup message.
  - Deploy start runs migrations and a schema smoke check.
- **Evidence**:
  - bundle exec rspec spec/requests/operations_procurement_spec.rb.
  - bin/render-start.sh.
  - lib/tasks/ops_schema.rake.
  - UI_TEST_EMAIL=test@example.com UI_TEST_PASSWORD=Password123! bin/ui-screenshots (pending, Chrome not available).
  - Issue: ISS-026.

### IMP-028 Operations dashboards empty state guidance

- **Status**: Done
- **Date**: 2026-02-14
- **Why**: Operations dashboards should explain next steps when no IFS data is available.
- **Approach**:
  - Add a shared empty state panel with an Operations Imports call to action.
  - Render the panel on procurement, production, efficiency, quality, and BOM pages when data is empty.
- **Acceptance criteria**:
  - Each Operations dashboard shows a No data yet message with a link to Operations Imports when no records exist.
- **Evidence**:
  - bundle exec rspec spec/requests/operations_procurement_spec.rb.
  - browser:/tmp/codex_browser_invocations/d5dd6e13f42f9ee8/artifacts/tmp/screenshots/manual/operations-empty.png.
  - Issue: ISS-027.

### IMP-029 Contract period and milestone date inputs

- **Status**: Done
- **Date**: 2026-02-14
- **Why**: Multi select date fields made it easy to miss a month or day selection.
- **Approach**:
  - Switch contract period and milestone due dates to single date fields.
  - Surface validation errors with flash alerts.
- **Acceptance criteria**:
  - Periods and milestones save with a single date input and failed submits show errors.
- **Evidence**:
  - bundle exec rspec spec/requests/contract_periods_spec.rb spec/requests/delivery_milestones_spec.rb.
  - browser:/tmp/codex_browser_invocations/d5dd6e13f42f9ee8/artifacts/tmp/screenshots/manual/period-success.png.
  - browser:/tmp/codex_browser_invocations/d5dd6e13f42f9ee8/artifacts/tmp/screenshots/manual/period-failure.png.
  - Issue: ISS-028 and ISS-029.

### IMP-030 Cost entry live totals and visible inputs

- **Status**: Done
- **Date**: 2026-02-14
- **Why**: Numeric inputs should look interactive and totals should update while typing.
- **Approach**:
  - Add placeholders and help text for labor categories.
  - Add a live total cost panel driven by Stimulus.
- **Acceptance criteria**:
  - Cost entry form shows visible inputs and total updates with input changes.
- **Evidence**:
  - browser:/tmp/codex_browser_invocations/d5dd6e13f42f9ee8/artifacts/tmp/screenshots/manual/cost-total-live.png.
  - Issue: ISS-030.

### IMP-031 Risk register mitigation notes

- **Status**: Done
- **Date**: 2026-02-14
- **Why**: Risks need space to capture mitigation details alongside core metadata.
- **Approach**:
  - Add a mitigation field and update labels to use risk and opportunity terminology.
  - Update request specs to cover filters and creation.
- **Acceptance criteria**:
  - Risk register form includes mitigation notes and filters return scoped results.
- **Evidence**:
  - bundle exec rspec spec/requests/risks_spec.rb.
  - browser:/tmp/codex_browser_invocations/d5dd6e13f42f9ee8/artifacts/tmp/screenshots/manual/risks-index.png.
  - Issue: ISS-031.

### IMP-032 Operations import performance and resiliency

- **Status**: Done
- **Date**: 2026-02-07
- **Why**: Large XLSX uploads can exhaust memory on small instances and cause 502 responses.
- **Approach**:
  - Stream XLSX rows, batch insert rows, and move imports to a background job.
  - Add file size guardrails and clearer upload errors.
- **Acceptance criteria**:
  - Uploading an ops report creates a queued import and enqueues a job.
  - Oversized files return a 422 response with a helpful message.
- **Evidence**:
  - bundle exec rspec.
  - Issue: ISS-033.

### IMP-033 Operations import queue observability

- **Status**: Done
- **Date**: 2026-02-07
- **Why**: Queued imports need clearer status visibility and worker guidance so users know when the queue is draining.
- **Approach**:
  - Capture Active Job job identifiers and log enqueue and job lifecycle events.
  - Add a refreshable import history panel with a last updated timestamp.
  - Document the Solid Queue worker requirement for Render deployments.
- **Acceptance criteria**:
  - Ops imports store job identifiers and log start and finish events.
  - Import history includes a refresh action and last updated timestamp.
  - Render docs call out the worker start command and required environment variables.
- **Evidence**:
  - bundle exec rubocop; bundle exec brakeman; bundle exec bundler-audit check --update.
  - bundle exec rspec (fails: ops_imports_spec job_id assertion, missing tailwind.css, missing Chrome).
  - bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/cost_hub_import_spec.rb spec/system/navigation_spec.rb spec/system/navigation_routes_spec.rb spec/system/account_management_spec.rb (fails: missing tailwind.css).
  - bin/ui-screenshots (pending, Chrome not available).
  - browser:/tmp/codex_browser_invocations/b150e7c108c033dc/artifacts/artifacts/ops-imports.png.
  - Issue: ISS-034.

### IMP-034 Shared storage for Operations import files

- **Status**: Done
- **Date**: 2026-02-15
- **Why**: Solid Queue workers must access the same Active Storage files as the web service to process imports.
- **Approach**:
  - Switch production Active Storage to S3 with environment provided credentials.
  - Read import files via blob open in the job and surface a clear failure message when missing.
  - Add a job spec that stubs blob open using the XLSX fixture.
- **Acceptance criteria**:
  - Production config points to the shared S3 storage service.
  - Import job opens the blob and updates status for success and missing file scenarios.
  - Job spec verifies blob open is used.
- **Evidence**:
  - Issue: ISS-035.
  - bundle exec rubocop.
  - bundle exec brakeman.
  - bundle exec bundler-audit check --update.
  - bundle exec rspec (fails: missing tailwind.css, Chrome missing for system tests).
  - bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/cost_hub_import_spec.rb spec/system/navigation_spec.rb spec/system/navigation_routes_spec.rb spec/system/account_management_spec.rb (fails: missing tailwind.css).
  - bin/ui-screenshots (pending: Chrome missing).
  - PR: pending.
