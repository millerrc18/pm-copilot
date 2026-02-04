# Iteration 3A: Program scoped costs, cost entry CRUD, navigation cleanup, and charts

This ExecPlan is a living document. The sections `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` must be kept up to date as work proceeds.

This ExecPlan must be maintained in accordance with `.agent/PLANS.md` in this repository.

## Purpose / Big Picture

After this change, a user can manage costs as a first-class, program scoped ledger. They can enter costs manually, edit and correct imported costs, and see clear totals and simple charts without costs mixing across programs. The Cost Hub becomes a Workspace section, while the importer remains under Imports. Navigation becomes clearer, and the UI remains readable in dark mode.

A reviewer can verify the change by starting the server, creating two programs, entering costs for each, and confirming that Cost Hub totals and charts change only for the selected program. They can also edit a cost entry and see totals update immediately.

## Progress

- [x] (2026-02-03 17:00) Create or update `docs/quality/issue_log.md` and `docs/quality/improvement_log.md` with the initial findings and planned fixes.
- [x] (2026-02-03 17:05) Fix dark mode styling on Cost Import program select; add system test and screenshots.
- [x] (2026-02-03 17:10) Enforce program scoping for costs: data model, migrations, backfill, query audit; add tests.
- [x] (2026-02-03 17:15) Add CostEntry CRUD UI (create, edit, delete, duplicate) and wire it into Cost Hub; add end to end system tests.
- [x] (2026-02-03 17:20) Move Cost Hub nav into Workspace, keep importer under Imports, rename Docs to Knowledge Center; add nav tests and screenshots.
- [x] (2026-02-03 17:25) Add minimal charts to Cost Hub and Contract pages; ensure they respect program and time filters; add screenshots.
- [x] (2026-02-03 17:45) Run validation commands from `AGENTS.md` and capture evidence logs and screenshot paths.

## Surprises & Discoveries

- Observation: UI screenshots were pending because Chrome was unavailable in the environment.
  Evidence: docs/quality/issue_log.md ISS-013.

## Decision Log

- Decision: Treat program as the only cost boundary and require `CostEntry.program_id`.
  Rationale: Costs cannot be shared between programs and must never mix.
  Date/Author: 2026-02-03 Codex

- Decision: Use seeded demo data for screenshots instead of production credentials.
  Rationale: Keeps screenshots deterministic and avoids storing secrets.
  Date/Author: 2026-02-03 Codex

## Outcomes & Retrospective

- Summary of what was delivered: Program scoped costs, CRUD flows, navigation updates, and charts with system and model coverage.
- What remains: UI screenshots require Chrome for full coverage.
- Lessons learned: Keep chart containers stable for small viewports.

## Context and Orientation

The application is a Rails app with Programs as the top-level workspace object. Programs contain many Contracts, and Contracts have milestones, delivery units, and contract periods.

Cost tracking currently exists via an import workflow. Imported rows create CostEntry records. The Cost Hub aggregates costs and divides by delivered units to compute average cost per unit.

Key areas to inspect and update:

- Models: `app/models/program.rb`, `app/models/contract.rb`, `app/models/cost_entry.rb`, `app/models/cost_import.rb`.
- Controllers and views:
  - Cost hub: `app/controllers/cost_hub_controller.rb` and its views.
  - Cost imports: `app/controllers/cost_imports_controller.rb` and its views.
  - Navigation: `app/views/shared/_sidebar.html.erb` and top bar.
- System tests: `spec/system/*` and any screenshot harness referenced by `bin/ui-screenshots`.

Terms:

- Program scoped: a cost entry belongs to exactly one program, and all cost totals, charts, and summaries include only entries for that program.
- Cost hub: the main cost workspace page showing totals, a table of cost entries, and charts.
- Importer: the UI for uploading a spreadsheet and creating cost entries.

## Plan of Work

Milestone 1: Establish logs and baseline expectations.

Create `docs/quality/issue_log.md` and `docs/quality/improvement_log.md` if they do not exist. Record known issues: cost import select readability, program scoping for costs, missing cost entry edit and creation UI, and desired charts.

Milestone 2: Dark mode readability fix for Cost Import program select.

Update the Cost Import form to ensure the program select renders with dark background and readable text, including focus styles. Add a system test that verifies the element has the expected classes and include screenshots.

Milestone 3: Program scoped costs.

Ensure `CostEntry` belongs_to `Program` with a required `program_id`. Add a migration to enforce NOT NULL at the database layer. Backfill existing data. Audit all aggregations and queries so they are always scoped by program. Add tests that create two programs with different costs and assert that the cost hub totals never mix.

Milestone 4: CostEntry CRUD UI.

Add controller routes and views to create, edit, delete, and duplicate cost entries. Integrate actions into the Cost Hub table, and ensure totals and charts update after changes. Add end to end system tests covering create, edit, delete, duplicate.

Milestone 5: Navigation restructure.

Move Cost Hub into Workspace. Keep importer under Imports. Rename Docs to Knowledge Center and place it outside of Workspace. Add system tests verifying navigation grouping and screenshots for the sidebar.

Milestone 6: Charts and visualizations.

Add minimal charts for Cost Hub and Contract pages. Cost Hub charts should include cost over time and cost composition. Contract page should include delivered units over time. Charts must respect program filtering and time slicing.

Milestone 7: Validation and evidence.

Run validation commands from `AGENTS.md`. Ensure `bin/ui-screenshots` produces deterministic files under `tmp/screenshots/ui/...`. Update logs to reflect what was completed and any remaining work.

## Concrete Steps

All commands are run from the repository root.

1) Setup

   - bundle install
   - RAILS_ENV=test bin/rails db:prepare

2) Run targeted system specs during development

   - bundle exec rspec spec/system/navigation_spec.rb
   - bundle exec rspec spec/system/cost_hub_spec.rb
   - bundle exec rspec spec/system/cost_entry_spec.rb

3) Run full validation

   - bundle exec rubocop
   - bundle exec brakeman
   - bundle exec bundler-audit check --update
   - bundle exec rspec
   - bin/ui-screenshots

Expected results:

- All specs pass in the configured test environment.
- `bin/ui-screenshots` produces viewports for desktop, iPad, iPhone and saves to `tmp/screenshots/ui/...`.

## Validation and Acceptance

Acceptance is based on user-visible behavior and tests:

- Program scoping:
  - When two programs exist, costs entered for Program A do not appear in Program B cost hub totals.
  - System spec demonstrates this by creating costs for both programs and asserting totals.

- Cost entry CRUD:
  - A user can create a cost entry from the UI and it appears in the cost hub.
  - A user can edit an imported cost entry and totals update.
  - A user can delete a cost entry and it disappears and totals update.
  - A user can duplicate a cost entry to create a new entry with the same fields.

- Navigation:
  - Cost Hub is under Workspace.
  - Importer remains under Imports.
  - Docs is renamed to Knowledge Center and is outside Workspace.
  - Navigation system spec asserts this.

- UI:
  - Cost import program select is readable in dark mode.
  - Screenshot evidence exists for all viewports.

- Charts:
  - Charts render on Cost Hub and Contract pages with seeded data.
  - Charts respect program filter and time slicer.

## Idempotence and Recovery

- All migrations must be reversible.
- Any backfill script should be safe to run multiple times.
- If a migration fails, roll back with `bin/rails db:rollback` and rerun after correcting.
- Screenshot artifacts remain in `tmp/` and are not committed.

## Artifacts and Notes

- Store screenshot outputs under `tmp/screenshots/ui/...`.
- In PR description, include:
  - commands run and results
  - screenshot file paths
  - summary of changes
  - links to updated issue and improvement logs

## Interfaces and Dependencies

- Prefer existing Rails patterns in the repo for controllers and forms.
- For charts, choose a minimal approach (Chartkick + Chart.js or Chart.js via Stimulus) and document it in the Knowledge Center.
- Avoid adding many new dependencies; keep changes small and testable.
