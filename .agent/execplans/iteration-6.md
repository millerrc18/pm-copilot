# ExecPlan-6: Refine R&O Hub (liabilities vs assets) and build a Planning Hub (timeline + views + dependencies)

This ExecPlan is a living document. The sections Progress, Surprises & Discoveries, Decision Log, and Outcomes & Retrospective must be kept up to date as work proceeds.

If `.agent/PLANS.md` exists in this repository, this plan must be maintained in accordance with it.

## Purpose / Big Picture

We will ship two highly polished, UX-first hubs:

1) Risks & Opportunities (R&O) Hub
- Treat Risks as liabilities and Opportunities as assets.
- Provide an accurate, defensible scoring model (probability × impact) and risk burndown that shows whether overall exposure is improving over time. The risk scoring and burndown should align with Disciplined Agile guidance (risk magnitude = probability × impact; risk burndown trends the total risk score over time). :contentReference[oaicite:1]{index=1}
- Introduce a Net Exposure metric (Opportunity exposure minus Risk exposure) that can later feed the PPA forecast hub as a negative adjustment when liabilities dominate.

2) Planning Hub
- Provide a real planning workspace that supports roadmap style planning for programs and optionally contracts.
- Include a Timeline view with dependencies, saved views, and filters. Saved views and dependency visualization should follow proven patterns like “saved timeline views” and “dependencies view” found in best-in-class planning tools. :contentReference[oaicite:2]{index=2}
- Prioritize a coherent, consistent UI with strong information architecture and low-friction workflows.

Non-negotiables:
- Program is top-level for both hubs.
- No binary assets committed (avoid .xlsx templates in git; generate templates dynamically).
- All required tests run and are documented.
- Deterministic UI screenshots produced by `bin/ui-screenshots` for both hubs.
- Codex must keep a running implementation log for you to share back.

## Running Log Requirement (for Codex)

Create and maintain:
- `docs/quality/iteration_logs/execplan-6-log.md`

Rules:
- Update the log at every milestone completion and at every “stop point” (before pushing).
- Each entry must include: timestamp, summary, files changed, commands run, test outcomes, screenshots produced (paths), and any follow-ups.

This log is separate from `docs/quality/issue_log.md` and `docs/quality/improvement_log.md` (those should also be updated).

## Progress

- [ ] (T0) Audit current main branch state for R&O and Planning (routes, models, pages, tests, screenshots).
- [ ] (T_toggle) Create `docs/quality/iteration_logs/execplan-6-log.md` and write initial baseline entry.
- [ ] (M1) R&O Hub: Data model alignment (liabilities/assets semantics), add Net Exposure, and ensure program scoping is correct.
- [ ] (M2) R&O Hub: UX overhaul (dashboard layout, burndown, opportunity trend, heatmaps, table, saved views behavior).
- [ ] (M3) R&O Hub: Tests + screenshot coverage + CI browser reliability.
- [ ] (M4) Planning Hub: Data model (Plan Items + dependencies + views) and core CRUD.
- [ ] (M5) Planning Hub: UX (timeline, dependency view, filters, saved views, program/contract scoping).
- [ ] (M6) Planning Hub: Tests + screenshot coverage + documentation updates.
- [ ] (M7) Final validation: run full command set, confirm acceptance criteria, update docs and logs.

## Surprises & Discoveries

(Keep updated during implementation with concise evidence.)

- Observation:
  Evidence:

## Decision Log

(Keep updated during implementation.)

- Decision:
  Rationale:
  Date/Author:

## Outcomes & Retrospective

(Complete at the end with what shipped, what did not, and what to do next.)

## Context and Orientation

R&O Hub design requirements:
- Risks are liabilities: they reduce the program’s future expected value.
- Opportunities are assets: they increase the program’s future expected value.
- Score model: magnitude = probability × impact. This is a recognized simple quantitative approach for ranking risk and is explicitly described in Disciplined Agile resources. :contentReference[oaicite:3]{index=3}
- Risk burndown: trend the total risk score over time (sum of magnitudes) and show how it changes as risks are addressed. :contentReference[oaicite:4]{index=4}

Planning Hub design requirements:
- Timeline planning must support dependency visualization and saved views, because these are core affordances in mature planning systems. :contentReference[oaicite:5]{index=5}
- Provide strong filters, groupings, and persisted views.

Testing + screenshots:
- This repo uses RSpec and a system test driver requiring Chrome/Chromium availability for UI screenshots.
- If CI lacks a Chrome binary, install it explicitly in GitHub Actions and capture the installed path. A common approach is to use a setup action that exposes `chrome-path`. :contentReference[oaicite:6]{index=6}

## Plan of Work

### Milestone 0: Audit and baseline

Goal:
Understand what already exists, so we refactor rather than duplicate.

Steps:
1) Inventory current R&O Hub:
   - Models (names, fields, validations, associations)
   - Controllers/routes
   - UI pages and partials
   - Saved views implementation (if any)
   - Charting library choices (if any)
   - Existing specs and failing specs
2) Inventory current Planning Hub (likely incomplete or placeholder):
   - Routes/pages
   - Any models or stubs
3) Write baseline notes into `docs/quality/iteration_logs/execplan-6-log.md`:
   - Current behavior screenshots (manual notes)
   - Current failing/passing tests
   - Gaps vs this plan

Acceptance:
- Log file exists and documents baseline clearly.

### Milestone 1: R&O Hub model semantics and metrics (liabilities vs assets)

Goal:
Make the underlying math and semantics correct and future-proof for PPA integration.

Required data semantics:
- Risk magnitude: `risk_score = probability * impact`
- Opportunity magnitude: `opp_score = probability * impact`
- Liability/asset interpretation:
  - Risks contribute negative exposure.
  - Opportunities contribute positive exposure.
- Net exposure:
  - `net_exposure = opportunity_total - risk_total`
  - If negative, liabilities outweigh assets, which should be a negative input to PPA later.
- Keep Program as required scope:
  - Every record must have `program_id`.
  - Contract may be optional (linking), never required.

Implementation details:
1) Normalize the model:
   - If the repo uses one model for both risks and opportunities, retain it (with `item_type` enum).
   - Ensure probability and impact are validated and bounded.
2) Add “exposure” helpers:
   - `risk_total_exposure(scope)` returns sum of open risk scores
   - `opportunity_total_exposure(scope)` returns sum of open opportunity scores
   - `net_exposure(scope)` returns opportunity minus risk
3) Add snapshots if not already implemented:
   - Program daily snapshot with risk_total and opportunity_total by date.
   - This powers burndown and trend charts.

Important: Risk burndown should track “risk score trend” (sum of probability × impact for risks) over time as described by Disciplined Agile. :contentReference[oaicite:7]{index=7}

Acceptance:
- Net exposure is computed and displayed accurately for a seeded dataset.
- Program scoping cannot be bypassed.

### Milestone 2: R&O Hub UX and feature completeness

Goal:
Deliver a best-in-class interface that is consistent with your app’s design language and feels polished.

Page IA (information architecture):
- Workspace nav: “Risks & Opportunities”
- Page top bar:
  - Program selector (required)
  - Date range (affects charts and table)
  - Status filter (open, in progress, mitigated, closed)
  - Owner filter (All, Mine)
  - Type filter (Risks, Opportunities, All)
  - Search
  - Saved views dropdown (Save, Update, Set default, Manage)
- Summary tiles row:
  - Open Risks (count)
  - Open Opportunities (count)
  - Risk Exposure (sum)
  - Opportunity Exposure (sum)
  - Net Exposure (opportunity minus risk) with clear sign indication
  - Due Soon (count)
- Analytics:
  - Risk Burndown chart (Actual vs Target)
  - Opportunity Trend chart (assets over time)
  - Net Exposure Trend (optional but recommended if space allows)
  - Heatmap (5x5) for risks and opportunities (toggle)
- Register table:
  - Strong column hierarchy and actions
  - Quick close/mitigate flows with required resolution notes
  - Inline edit only if it does not degrade clarity

Saved views behavior:
- Views persist per user and store:
  - filters, sorts, program, date range
- Views are shareable via URL query params.
- Default view automatically loads on page entry.
This mirrors mature “saved views” patterns seen in planning tools. :contentReference[oaicite:8]{index=8}

Acceptance:
- A user can create risks and opportunities, see net exposure update immediately, and save a preferred view that persists on refresh.

### Milestone 3: R&O tests, screenshots, and CI reliability

Goal:
Make the feature safe and easy to validate.

Tests to add or refine:
1) Model specs:
   - program_id required
   - probability/impact bounds
   - score calculation
   - net exposure calculation from seeded records
2) System specs:
   - create risk, create opportunity
   - close risk reduces risk exposure and changes burndown series
   - saved view persists and can be set default
   - URL tampering cannot access another program
3) Snapshot specs:
   - snapshot upsert is idempotent
   - backfill task produces correct totals

Screenshots:
- Update `bin/ui-screenshots` to include:
  - R&O hub default view
  - R&O hub heatmap visible
  - R&O hub with filters applied (mine, open only)
  - R&O create modal/page open
- Save under:
  - `tmp/screenshots/ui/risks_opportunities/...`

CI browser reliability:
- Ensure Chrome/Chromium is installed in CI and the driver uses the correct binary path.
- Use a deterministic install method and capture the installed path (for example a setup step that outputs `chrome-path`). :contentReference[oaicite:9]{index=9}
- Document the env vars and local setup steps in `AGENTS.md`.

Acceptance:
- All required commands run cleanly, or pre-existing failures are explicitly documented as out of scope.
- `bin/ui-screenshots` produces the expected files.

### Milestone 4: Planning Hub model and core CRUD

Goal:
Create a real planning system, not just a page.

Core model: PlanItem
- program_id required
- contract_id optional
- fields:
  - title, description
  - item_type (initiative, milestone, deliverable, task)
  - owner_id optional
  - status (planned, in_progress, blocked, done)
  - start_on, due_on
  - percent_complete (optional)
  - sort_order (for stable ordering)
- dependencies:
  - PlanDependency model linking predecessor -> successor
  - validate no circular dependencies (at least basic cycle detection)
  - store dependency_type if desired (blocks, relates)

Rationale:
Planning tools rely heavily on dependencies and timeline structure; dependency visualization is a first-class concept in mature planning systems. :contentReference[oaicite:10]{index=10}

CRUD:
- Create/edit PlanItems
- Create/remove dependencies
- Move status and update dates quickly

Acceptance:
- User can create a plan item and add a dependency.

### Milestone 5: Planning Hub UX (timeline + dependencies + saved views)

Goal:
Deliver a planning UI that feels modern, clean, and useful daily.

Views (tabs):
- Timeline (default)
- List
- Dependencies
- Calendar (optional if achievable without compromising quality)

Key UX behaviors inspired by best-in-class patterns:
- Timeline view supports filtering and saved views conceptually similar to “saved timeline views.” :contentReference[oaicite:11]{index=11}
- Dependencies view shows items as tiles with arrows and supports filtering and grouping. :contentReference[oaicite:12]{index=12}
- Dependencies rendering includes a visual warning state if dates conflict (red line or badge concept). :contentReference[oaicite:13]{index=13}

Timeline specifics:
- Program required selector.
- Grouping options:
  - by contract (optional)
  - by owner
  - by status
- Columns:
  - start date, due date, status, owner, dependencies count
- Dependency display:
  - badges or lines style toggle (optional)
- Right-side detail drawer:
  - clicking an item opens details, edits, and dependency actions without navigating away

Saved views:
- Save filters/grouping/sort and default view.
- Apply instantly via Turbo (no full page refresh).

Acceptance:
- A user can filter the timeline, save a view, refresh, and see the same view.
- Dependencies view renders correctly and is filterable.

### Milestone 6: Planning Hub tests, screenshots, docs

Tests:
1) Model specs:
   - PlanItem requires program
   - Dependency cannot create a cycle (basic test)
2) System specs:
   - create plan item
   - add dependency
   - saved view persists
   - program scoping enforced

Screenshots:
- Add to `bin/ui-screenshots`:
  - planning timeline default
  - planning dependencies view
  - planning item drawer open
- Save under:
  - `tmp/screenshots/ui/planning_hub/...`

Docs updates:
- `docs/quality/issue_log.md` updated with any gaps discovered and known issues.
- `docs/quality/improvement_log.md` updated with shipped improvements.
- `AGENTS.md` updated:
  - test commands (if changed)
  - local and CI notes for Chrome/Chromium
  - screenshot expectations
  - env var placeholders (no real credentials)

Acceptance:
- Planning hub works end-to-end with deterministic screenshots generated.

### Milestone 7: Final validation and acceptance pass

Run the required suite:
- bundle exec rubocop
- bundle exec brakeman
- bundle exec bundler-audit check --update
- RAILS_ENV=test bin/rails db:prepare
- RAILS_ENV=test bin/rails tailwindcss:build
- bundle exec rspec
- bin/ui-screenshots

Ensure screenshots exist:
- `tmp/screenshots/ui/risks_opportunities/...`
- `tmp/screenshots/ui/planning_hub/...`

Update the running log and both quality logs with final results.

## Concrete Steps

Work from repo root.

1) Create branch:
   - git checkout -b execplan-6-hubs

2) Baseline audit:
   - Identify current files and write baseline log entry.

3) Implement milestone-by-milestone with small commits:
   - After each milestone, update `docs/quality/iteration_logs/execplan-6-log.md` and run relevant tests.

4) Before PR:
   - Ensure no binary assets staged:
     - git diff --cached --name-only
   - Run full command list.

## Validation and Acceptance

R&O Hub acceptance:
- Risks and opportunities are program-scoped.
- Risk exposure and opportunity exposure compute correctly.
- Net exposure is clearly presented and updates immediately.
- Risk burndown trends risk score over time (sum of probability × impact). :contentReference[oaicite:14]{index=14}
- Saved views work (save, set default, persist on refresh).

Planning Hub acceptance:
- User can create plan items and dependencies.
- Timeline view is useful for real planning.
- Dependencies view shows directional relationships and supports filtering. :contentReference[oaicite:15]{index=15}
- Saved views work similarly to other hubs and align with established planning patterns. :contentReference[oaicite:16]{index=16}

Evidence requirements:
- Deterministic screenshots exist under tmp/screenshots/ui for both hubs.
- Running log is complete and readable.

## Idempotence and Recovery

- Snapshot generation must be idempotent.
- Backfill tasks must be safe to rerun.
- Saved views must be safe to apply repeatedly.
- If screenshots fail due to missing Chrome/Chromium:
  - Fail loudly with actionable setup instructions and a CI install approach that exposes the installed browser path. :contentReference[oaicite:17]{index=17}

## Artifacts and Notes

Update:
- `docs/quality/iteration_logs/execplan-6-log.md`
- `docs/quality/issue_log.md`
- `docs/quality/improvement_log.md`
- `AGENTS.md`

Keep all evidence concise but sufficient: tests run, outcomes, and screenshot paths.
