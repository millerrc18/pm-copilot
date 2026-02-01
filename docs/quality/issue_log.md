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
