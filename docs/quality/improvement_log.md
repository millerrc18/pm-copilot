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
