# Iteration 7: Operations Intelligence from IFS Reports (Procurement, Production, Efficiency, Quality, BOM)

This ExecPlan is a living document. The sections Progress, Surprises & Discoveries, Decision Log, and Outcomes & Retrospective must be kept up to date as work proceeds.

If `.agent/PLANS.md` exists in this repository, this plan must be maintained in accordance with it.

## Purpose / Big Picture

We will turn IFS-exportable reports (as represented by the workbook tabs) into a cohesive, high-utility Operations Intelligence area inside PM Copilot.

At the end of Iteration 7, a user can:

- Import common IFS reports (Materials, Shop Orders, Shop Order Operations, Historical Efficiency, Scrap, MRB, BOM) into PM Copilot, scoped to a Program.
- Navigate to Workspace > Operations and use polished dashboards for:
  1) Procurement (materials, suppliers, spend, lead-time risk indicators if present)
  2) Production (shop orders and operations board, status views, drilldown)
  3) Efficiency (planned vs actual labor, variance)
  4) Quality (scrap and MRB, pareto + trend)
  5) BOM Explorer (tree, flattened rollup, where-used)
- Apply filters consistently across all pages, and save preferred views per page (saved views).
- See responsive layouts that look intentional on desktop and iPad, with simplified but usable layouts on iPhone.
- Generate deterministic UI screenshots for each Operations page via `bin/ui-screenshots`.
- Run a complete test suite and produce clear documentation and logs.

We will prioritize UI/UX design quality, information architecture, and correctness over speed.

## Non-Negotiables

- Program is the top-level scope for all Operations data and views.
- No binary assets committed to git (no static .xlsx templates in the repo). Templates must be generated dynamically.
- Imports must be idempotent and auditable: users can see what was imported, when, and what changed.
- UI must be consistent: shared Filter Bar pattern, shared Summary Cards pattern, shared Table pattern, consistent chart styling.
- Saved views must work consistently across all new pages.
- Add a running implementation log that you (the user) can share back after completion.

## Running Log Requirement

Create and maintain a running log file:

- `docs/quality/iteration_logs/iteration-7-log.md`

Rules:
- Update at every milestone completion and at any stop point before pushing.
- Each entry includes:
  - timestamp
  - what changed (user-visible)
  - files changed (high level)
  - commands run
  - tests run and outcomes
  - screenshots produced (paths)
  - known issues and next steps

Also update:
- `docs/quality/issue_log.md`
- `docs/quality/improvement_log.md`

## Progress

- [ ] (M0) Audit: workbook tabs, current import patterns, saved views patterns, existing UI components and charts.
- [ ] (M0) Create `docs/quality/iteration_logs/iteration-7-log.md` and write baseline entry.
- [ ] (M1) Imports backbone: standardized Ops imports with program scoping, import history, and normalization.
- [ ] (M2) Procurement dashboard (Materials) with filters, KPIs, charts, and table drilldown.
- [ ] (M3) Production board (Shop Orders + Operations) with status views and order drilldowns.
- [ ] (M4) Efficiency dashboard (planned vs actual labor) with variance insights.
- [ ] (M5) Quality dashboard (Scrap + MRB) with pareto + trend + drilldown.
- [ ] (M6) BOM Explorer (tree, flattened rollup, where-used).
- [ ] (M7) Saved views for all Operations pages, consistent UX, default view behavior.
- [ ] (M8) Documentation hub updates, tests, deterministic screenshots, CI browser reliability notes.
- [ ] (M9) Final validation and acceptance pass, close logs.

## Surprises & Discoveries

(Keep updated during implementation with concise evidence snippets.)

- Observation:
  Evidence:

## Decision Log

(Keep updated during implementation.)

- Decision:
  Rationale:
  Date/Author:

## Outcomes & Retrospective

(Complete at the end with what shipped, what did not, what to do next.)

## Context and Orientation

This repository is a Rails application with:
- Devise authentication
- Turbo/Tailwind UI patterns
- RSpec for tests including system specs
- `bin/ui-screenshots` for deterministic UI capture (expected output under `tmp/screenshots/ui/...`)

The user can export reports from IFS and import them into the app. The workbook tabs represent report types we can reliably pull from IFS.

Important repo constraints:
- Past work has run into PR failures when binary files are committed. Avoid committing any `.xlsx`, `.png`, `.ico`, etc. Generate templates dynamically.

User experience constraints:
- Desktop and iPad are primary UX targets for Operations dashboards.
- iPhone should have a simplified but usable layout, not a broken desktop layout squeezed into mobile.

## Iteration Scope

We will build:

1) Operations imports:
- Materials
- Shop Orders
- Shop Order Operations
- Historical Efficiency
- Scrap
- MRB (Part Details + Dispo Lines, if both exist)
- BOM (Indented and/or PS tabs)

2) Operations dashboards:
- Procurement (Materials)
- Production (Shop Orders + Ops)
- Efficiency (Historical Efficiency)
- Quality (Scrap + MRB)
- BOM Explorer

3) Shared UX system:
- Standard Filter Bar
- Summary Cards
- Charts
- Tables
- Saved views per page

4) Documentation:
- Knowledge Center pages for each dashboard
- Import how-to guide
- Saved views guide

5) Tests + screenshots:
- Model specs
- System specs
- UI screenshots across a stable viewport matrix

## Milestone 0: Audit and UX spec foundation

Goal:
Know exactly what exists in the repo today and define reusable UI patterns before implementing dashboards.

Steps:
1) Inspect the workbook and extract a mapping doc:
   - For each report tab, list:
     - primary key candidates
     - date fields
     - numeric measures
     - join keys (part number, order number, supplier, etc.)
     - which dimensions are available for filtering
   - Write this mapping to:
     - `docs/operations/ifs_report_mappings.md`

2) Audit current repo patterns:
   - Existing import models/services and how they validate headers
   - Existing saved views behavior and data model
   - Existing chart approach (if any)
   - Existing table patterns (pagination, sorting, search)

3) Add a lightweight UX spec page:
   - `docs/operations/ui_system.md`
   - Define:
     - filter bar layout and behavior
     - applied filters display
     - saved view UX (save, update, set default)
     - empty states, loading states, error states
     - mobile behavior rules

Acceptance:
- Mapping doc exists.
- UI system doc exists.
- Baseline running log entry written.

## Milestone 1: Imports backbone and audit trail

Goal:
Implement a standardized import pipeline for Operations reports with program scoping and import history.

Design:
- Create an `OpsImport` concept that is consistent across all report types.
- Each import creates an import record (batch) plus normalized rows in dedicated tables per report type.
- Each normalized row includes:
  - program_id (required)
  - import_batch_id (required)
  - source_row_hash or source_row_number for traceability
  - raw fields needed for drilldown and join keys

Features:
- An "Operations Imports" page that:
  - shows import history by program
  - shows per-import stats: rows imported, rows rejected, key aggregates
  - links to the relevant dashboard view pre-filtered to that import (optional but useful)

Template downloads:
- Provide downloadable templates per report type, generated dynamically:
  - CSV is acceptable as a template format if Excel output is hard to generate without committing binaries.
  - If generating XLSX dynamically, do not commit the XLSX file, generate it at request time.

Idempotence:
- If the same file is imported twice for the same program, the UI should make this obvious.
- Avoid accidental duplication by using:
  - checksum comparison
  - or a stable "import signature" with a warning and an optional "replace" flow.

Acceptance:
- Each report type import works from the UI.
- Import history appears and is program scoped.
- No binary templates exist in the repo.

## Milestone 2: Procurement dashboard (Materials)

Goal:
A user can see material cost drivers, supplier concentration, and drill into parts.

UI requirements:
- Standard filter bar:
  - Program (required)
  - Date range (default to last 90 days or most recent period available)
  - Supplier
  - Commodity
  - Buyer (if available)
  - Part number search

Summary cards:
- Material spend (period)
- Top supplier (period)
- Top commodity (period)
- Unique parts count

Charts:
- Spend by commodity (bar)
- Spend over time (line)

Table:
- Default: parts by spend (sortable)
- Drilldown: part details and supplier list if present

Acceptance:
- Filters apply without full page refresh (Turbo frame updates).
- Saved views can capture the filter state (wired in Milestone 7 but page should use the standard Filter Bar component now).

## Milestone 3: Production board (Shop Orders + Operations)

Goal:
Provide a production view that answers:
- What is late?
- What is in progress?
- Where is WIP stuck?

UI:
- Tabs inside Production:
  - Orders (list/board)
  - Operations (by shop order)
  - Timeline (optional if feasible without compromising quality)

Default:
- Orders list filtered to open or active orders in the current time window.

Board/list features:
- Status grouping (Released, Started, In Progress, Complete, Closed or closest IFS mapping)
- SLA style indicators (late, due soon, on track)
- Drilldown drawer for a shop order:
  - header details
  - operations sequence table (from Shop Order Operations)
  - start/finish dates, status, and any notes fields

Acceptance:
- Production page is useful even without perfect IFS status mapping. Provide a clear mapping section in docs explaining how statuses are interpreted.

## Milestone 4: Efficiency dashboard (Historical Efficiency)

Goal:
Make planned vs actual labor variance visible and actionable.

UI:
- Standard filter bar:
  - Program (required)
  - Date range
  - Labor category (if present, eg BAM, ENG, MFG)
- Summary cards:
  - Planned hours
  - Actual hours
  - Variance hours
  - Variance percent
- Charts:
  - Planned vs actual trend
  - Variance bars by week

Drilldown table:
- weekly rows with planned, actual, delta, percent

Acceptance:
- Users can quickly see where the variance is coming from, with drilldown supporting leadership questions.

## Milestone 5: Quality dashboard (Scrap + MRB)

Goal:
Provide quality and cost of poor quality visibility.

UI:
- Standard filter bar:
  - Program (required)
  - Date range
  - Part
  - Reason code
  - Disposition
- Summary cards:
  - Scrap cost total (period)
  - MRB open count
  - Top defect reason
  - Top part by scrap

Charts:
- Pareto for top reasons by scrap cost (bar, sorted)
- Scrap cost over time (trend)

Table:
- Scrap records with sortable cost
- MRB records with status and disposition

Acceptance:
- Clear, non-confusing definitions in tooltips or inline helper text (what counts as open MRB, what is scrap cost source).

## Milestone 6: BOM Explorer and Where-Used

Goal:
Allow browsing of multi-level BOMs and answering where-used questions.

UI:
- Standard filter bar:
  - Program (required)
  - Assembly/Top part selector
  - Effective date (optional if data supports it)
- Views:
  - Tree (indented)
  - Flattened rollup
  - Where-used

Tree view requirements:
- Expand/collapse per level
- Visual indentation and level indicator
- Component row shows: part, description (if available), qty per, unit, and a link to where-used

Flattened view requirements:
- rollup qty (aggregate)
- sortable by qty and part

Where-used:
- input component part
- show parent assemblies and levels

Acceptance:
- Tree renders without excessive load time.
- Where-used returns a useful list and does not require perfect cross-program linking.

## Milestone 7: Saved Views for Operations pages

Goal:
Users can save their preferred filters and page state for each Operations page and return to it.

Behavior:
- Saved views are per user, per page key.
- Each saved view stores:
  - filters (query params)
  - table state (sort, visible columns, density if implemented)
- Default view:
  - user can set a default saved view per page
  - default applies automatically on page load

UI:
- Saved Views dropdown in the standard filter bar:
  - Save as new
  - Update existing
  - Set default
  - Manage views

Acceptance:
- Saved views persist across sessions.
- Saved views apply instantly without full refresh.

## Milestone 8: Documentation, tests, deterministic screenshots, CI notes

Documentation:
Add Knowledge Center sections:
- `docs/knowledge_center/operations_overview.md`
- `docs/knowledge_center/procurement_dashboard.md`
- `docs/knowledge_center/production_dashboard.md`
- `docs/knowledge_center/efficiency_dashboard.md`
- `docs/knowledge_center/quality_dashboard.md`
- `docs/knowledge_center/bom_explorer.md`
- `docs/knowledge_center/imports_ops_reports.md`
- `docs/knowledge_center/saved_views.md`

Tests:
- Add model specs for each normalized table:
  - validations
  - scoping to program
- Add importer specs:
  - required headers
  - row parsing and reject behavior
- Add system specs:
  - import each report type successfully
  - dashboards render for seeded data
  - filters apply
  - saved views persist

Screenshots:
Update `bin/ui-screenshots` to generate deterministic screenshots for:
- procurement
- production
- efficiency
- quality
- bom explorer

Output paths:
- `tmp/screenshots/ui/operations/procurement/...`
- `tmp/screenshots/ui/operations/production/...`
- `tmp/screenshots/ui/operations/efficiency/...`
- `tmp/screenshots/ui/operations/quality/...`
- `tmp/screenshots/ui/operations/bom/...`

Viewport matrix (stable and repeatable):
- Desktop: 1440x900
- iPad: 1024x1366
- iPhone: 390x844

CI browser reliability:
- If system specs and screenshots require Chrome/Chromium, document:
  - how to install it locally (Codespace)
  - how to ensure it exists in CI
- Update `AGENTS.md` with environment expectations:
  - no real credentials
  - placeholder UI_TEST_EMAIL and UI_TEST_PASSWORD
  - any required browser path env vars if needed

Acceptance:
- All required commands in `AGENTS.md` pass, or pre-existing failures are clearly documented with scope notes.
- Screenshot runner produces output under the expected folders.

## Milestone 9: Final validation and acceptance pass

Run the required suite from `AGENTS.md` (must match repo reality):
- bundle exec rubocop
- bundle exec brakeman
- bundle exec bundler-audit check --update
- RAILS_ENV=test bin/rails db:prepare
- RAILS_ENV=test bin/rails tailwindcss:build
- bundle exec rspec
- bin/ui-screenshots

Update logs:
- `docs/quality/iteration_logs/iteration-7-log.md` final entry
- `docs/quality/issue_log.md`
- `docs/quality/improvement_log.md`

Acceptance checklist:
- Operations nav and pages exist and are coherent.
- Imports work and are auditable.
- Dashboards provide real insight with drilldown.
- Saved views work on all Operations pages.
- UI is responsive and intentional on desktop, iPad, iPhone.
- Documentation is present and accurate.
- Tests and screenshots provide confidence.

## Concrete Steps

From repo root:

1) Branch:
   - git checkout -b iteration-7-operations-intelligence

2) Read and follow `AGENTS.md` for required commands, screenshot expectations, and env vars.

3) Implement milestone-by-milestone with small commits.
   - After each milestone:
     - update running log
     - run the narrowest relevant test subset
     - keep UI changes consistent with the shared UI system

4) Before PR:
   - verify no binary assets staged:
     - git diff --cached --name-only
   - run full command list from `AGENTS.md`

## Idempotence and Recovery

- Imports must be safe to retry. If a partial import fails, no partial normalized rows should remain.
- Import batches should be traceable and reversible:
  - provide a safe delete flow for an import batch that removes its normalized rows (admin-only if needed).
- Saved views should be safe to apply repeatedly.

## Notes on Assumptions

To keep progress unblocked, this plan assumes:
- Program is required for Operations data.
- Where the workbook has multiple similar BOM tabs, implement one normalized representation and map others into it.
- If a field does not exist in a report export, do not fake it. Hide related filters and show helpful empty states.

If any of these assumptions conflict with actual IFS export formats, document the delta in the running log and adjust parsing rules and docs accordingly.
