# Restore Operations Procurement stability and guardrails

This ExecPlan is a living document. The sections Progress, Surprises & Discoveries, Decision Log, and Outcomes & Retrospective must be kept up to date as work proceeds.

If a PLANS.md file is checked into the repo, reference the path to that file here from the repository root and note that this document must be maintained in accordance with it. This plan follows .agent/PLANS.md.

## Purpose / Big Picture

Operations Procurement is throwing production 500 errors when the database schema is missing ops tables or saved filter columns. After this change, Operations Procurement should load safely even with empty data, and missing schema should render a friendly 503 page with a clear migration instruction. Deploys must run migrations automatically, and a smoke check must fail deploys if ops schema is missing. This should be visible by visiting /operations/procurement without errors, seeing empty states when no data exists, and seeing a 503 setup screen when schema is missing.

## Progress

- [x] Review current Operations Procurement controller, views, and routes to understand failure points and empty state behavior.
- [x] Capture local reproduction info and document constraints if production logs are not accessible in this environment.
- [x] Implement deploy migration guard and smoke check script and document in README.
- [x] Add controller rescue and friendly setup page, plus empty state handling for no programs or no ops data.
- [x] Add request specs for happy path and empty state, plus a schema error spec.
- [x] Update quality logs with evidence entries.
- [x] Run required tests and ui screenshots.
- [x] Commit changes and prepare PR summary.

## Surprises & Discoveries

Unable to access production logs from this environment, so the exact production exception and stack trace could not be captured here.
Playwright Chromium crashed when attempting to capture a UI screenshot in this environment.

## Decision Log

- Decision: Start with local code inspection and targeted guards for schema errors before adjusting views for empty states.
  Rationale: Minimizes risk and lets the rescue behavior inform UI changes.
  Date/Author: 2026-02-09 / Codex

## Outcomes & Retrospective

Added schema guardrails, deploy migration checks, and request specs for Operations Procurement. Empty state messaging now guides users without programs or procurement data. Tests were executed per requirements, with system UI coverage limited by missing Chrome and a Playwright crash in this environment.

## Context and Orientation

Operations Procurement uses current_user saved filters, queries OpsMaterial, and builds summary metrics and charts. Production may be missing ops tables or saved filter columns because migrations were not run. We need to guard for schema issues, enforce migrations on deploy, and ensure empty state UX for users without programs or ops data.

## Plan of Work

Start by locating the Operations Procurement controller, views, and any service objects, then identify the points that query ops tables or rely on saved filter columns. Add a rescue for ActiveRecord schema errors in the controller or a shared concern to render a 503 setup page and log a clear message. Add empty state logic in the controller and view to handle users without programs and no ops data. Add a deploy-time migration command and a smoke check task or script that validates ops tables and user columns; wire it in render.yaml or equivalent and document in README. Add request specs for the successful empty state, regular response, and schema error. Update docs/quality logs with evidence. Run required test commands and ui screenshot script.

## Concrete Steps

From /workspace/pm-copilot run:

  - bundle install
  - RAILS_ENV=test bin/rails db:prepare
  - Identify controller and views with rg "operations" and open relevant files.
  - Implement rescue and empty state adjustments in controller and view files.
  - Add deploy command and smoke check task or script, and update render.yaml and README.
  - Add request specs under spec/requests or spec/system as appropriate.
  - Update docs/quality/issue_log.md and docs/quality/improvement_log.md.
  - Run tests listed in AGENTS.md and bin/ui-screenshots.

## Validation and Acceptance

Run the full test list from AGENTS.md. Confirm request specs pass. Confirm the setup page renders 503 by stubbing a schema error in specs. Confirm empty state text renders when a user has no programs. Confirm migration guard script fails when ops tables or columns are missing. Capture ui screenshots via bin/ui-screenshots.

## Idempotence and Recovery

Each code change is additive and can be re-run. If smoke check fails, run migrations and rerun the script. If tests fail, revert the last commit and re-apply changes in smaller steps.

## Artifacts and Notes

Capture the key error message for schema missing in logs. Record deploy command in README. Document any limitations around accessing production logs.

## Interfaces and Dependencies

Use ActiveRecord for schema checks, Rails controllers and views for rendering, RSpec for request specs, and render.yaml or platform config for deploy commands.
