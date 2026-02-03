# Iteration 3A cost hub polish, program scoped costs, and first pass charts

This ExecPlan is a living document. The sections Progress, Surprises & Discoveries, Decision Log, and Outcomes & Retrospective must be kept up to date as work proceeds.

The plan follows .agent/PLANS.md from the repository root and must be maintained in accordance with it.

## Purpose / Big Picture

Users can manage costs per program without cross program leakage, enter costs manually, navigate the Cost Hub from Workspace, and view basic charts on Cost Hub and Contract pages. The cost import program select is readable in dark theme. This is visible by visiting the Cost Hub and Cost Import pages and seeing scoped totals, CRUD actions, and charts. It is validated by system specs and UI screenshots.

## Progress

- [x] Review existing Cost Hub, Cost Import, program selection, and data models for Program, Contract, CostImport, CostEntry, and DeliveredUnit.
- [x] Update Cost Import select styling and add system spec for class list, then update screenshots for required pages and viewports.
- [x] Enforce program scoped costs in database, models, imports, and aggregation queries, then add model and system specs for scoping.
- [x] Add cost entry CRUD with duplicate, update Cost Hub UI, and add system specs for CRUD behavior.
- [x] Update navigation to move Cost Hub under Workspace and update navigation specs and screenshots.
- [x] Add charts to Cost Hub and Contract pages with program and period filters, then add system specs for chart containers.
- [x] Update docs and logs, run required commands, commit, and create PR.

## Surprises & Discoveries

Database migrations were marked as applied because schema load had already assumed the version, so the schema file needed manual updates and a schema load to ensure the new cost imports table existed in tests.

## Decision Log

- Decision: Use Chartkick with Chart.js for first pass visuals.
  Rationale: Keeps integration small and uses Rails helpers with minimal custom JavaScript.
  Date/Author: 2025-09-21 Codex

## Outcomes & Retrospective

Program scoped costs, cost entry duplication, navigation updates, and chart containers landed with system and model coverage. Screenshot automation is blocked due to missing Chrome in the environment.

## Context and Orientation

Cost Hub and Cost Import pages exist in app views and system specs. Programs and Contracts are related, and CostEntry and CostImport store costs. Aggregations and totals are likely computed in controllers or models for Cost Hub and Contract pages. Navigation is defined in views or configuration.

## Plan of Work

First, locate the Cost Import form, Cost Hub views, program dropdown code, and model relationships by searching app and spec directories. Then update select styling on the Cost Import page with explicit Tailwind classes and add a system spec to assert the classes. Next, enforce program scoped costs by adding program_id to CostEntry, ensuring database constraints and model validation, backfilling data, and updating cost imports and aggregations to scope by program. Add model and system specs to cover scoping.

Then add a CostEntriesController with new, create, edit, update, destroy, and duplicate actions, update routes and views, and add buttons in Cost Hub. Add system specs to cover creating, editing, deleting, and duplicating cost entries. Update navigation to move Cost Hub under Workspace and adjust navigation specs. Add simple charts to Cost Hub and Contract pages using Chartkick and Chart.js, ensuring filters by program and period range, and add system specs to verify chart containers. Update quality logs and any knowledge center documentation about costs.

Finally, run required setup and test commands, run ui screenshots, confirm outputs, commit changes, and create a PR description with commands and screenshots.

## Concrete Steps

Run these commands from the repository root as needed:

  bundle install
  RAILS_ENV=test bin/rails db:prepare
  rg "Cost Import" app spec
  rg "Cost Hub" app spec
  rg "program" app/models app/views app/controllers spec

After updates, run validations:

  bundle exec rubocop
  bundle exec brakeman
  bundle exec bundler-audit check --update
  bundle exec rspec
  bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/cost_hub_import_spec.rb spec/system/navigation_spec.rb spec/system/navigation_routes_spec.rb spec/system/account_management_spec.rb
  bin/ui-screenshots

## Validation and Acceptance

Visit the Cost Import page and confirm the program select is readable in dark theme with focus ring. Visit Cost Hub with multiple programs and confirm totals do not mix. Use the UI to create, edit, delete, and duplicate cost entries, confirming totals update. Verify charts appear on Cost Hub and Contract pages and respond to program and period filters. System specs and model specs pass, and required screenshots exist under tmp/screenshots/ui.

## Idempotence and Recovery

Use migrations that can be run multiple times without data loss. If a backfill fails, rerun the migration or create a task to reapply program_id based on cost import and contract associations. Re run system specs and ui screenshots after fixes. Use git checkout to revert partial edits if needed.

## Artifacts and Notes

Capture the list of screenshot file paths from tmp/screenshots/ui for the PR description and final summary.

## Interfaces and Dependencies

Use Rails controllers and views, ActiveRecord associations and migrations, system specs with Capybara and Cuprite, and Chartkick with Chart.js. Ensure no Selenium usage.
