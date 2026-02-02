# Iteration 4B: Contracts default active-year + saved views

This ExecPlan is a living document. The sections **Progress**, **Surprises & Discoveries**, **Decision Log**, and **Outcomes & Retrospective** must be kept up to date as work proceeds.

If `.agent/PLANS.md` exists in this repository, this plan must be maintained in accordance with it. citeturn0search1

## Purpose / Big Picture

Default Contracts list to only contracts active in the current year, and allow users to choose and save a preferred view (active this year, next year, specific year, all).

## Progress

- [x] (2026-02-01 21:22) Read `.agent/AGENTS.md` and confirm required commands and screenshot expectations.
- [x] (2026-02-01 21:46) Complete Milestone 1.
- [x] (2026-02-01 22:03) Complete Milestone 2.
- [x] (2026-02-01 22:20) Complete Milestone 3.
- [x] (2026-02-01 22:53) Final validation: run all required commands; capture screenshots; update logs; prepare PR.

## Surprises & Discoveries

- Observation: Running `bin/rails db:migrate` invoked rails-erd checks and failed due to missing GraphViz.
  Evidence: `bin/rails db:migrate` output noted missing `dot` executable.

## Decision Log

- Decision: Store contracts saved view preferences on the user record using view and year columns.
  Rationale: Keeps preferences per user without adding extra tables.
  Date/Author: 2026-02-01 / Codex

## Outcomes & Retrospective

- Outcome: Contracts default to the active year, with saved views and updated coverage.
  Gaps: bin/ui-screenshots remains pending due to missing Chrome, but a Playwright screenshot was captured.
  Lessons learned: Build Tailwind assets before running UI focused system specs.

## Context and Orientation

This plan assumes a Rails app with Devise authentication and system specs using Capybara. Navigation uses a shared sidebar partial. The codebase already contains Programs, Contracts, a Cost Hub, and Import flows.

**Important constraint (to avoid Codex PR errors):** keep PRs text-only whenever possible. Avoid committing binary assets (for example `.xlsx`, `.png`, `.ico`). Prefer dynamic template generation for XLSX downloads rather than committing static templates. citeturn0search1



## Scope

- Define 'active in year' using overlap logic on contract date fields.
- Add filter UI and persist per-user preference.
- Apply saved preference automatically on next visit; default to current year if none.

## Plan of Work

### Milestone 1 - Model scopes and tests

Add scopes/helpers for active-in-year, active-this-year, active-next-year. Unit test overlap edge cases.

### Milestone 2 - Filters UI

Add filter control with year picker. Wire controller to scopes.

### Milestone 3 - Saved view

Persist selected filter as per-user preference. Add system spec proving it persists across reload/re-login.


## Concrete Steps

1. Create a branch for this ExecPlan:
   - `git checkout -b <branch-name>`

2. Implement in small commits. After each milestone:
   - Run the relevant test subset.
   - Run `bin/ui-screenshots` for UI changes.
   - Update `issue_log.md` and `improvement_log.md` (or the repo’s chosen log paths).

3. Before PR:
   - Ensure no binary files are staged: `git diff --cached --name-only`
   - Run the full required command list from `.agent/AGENTS.md`.

## Validation and Acceptance

Commands (minimum set, align with `.agent/AGENTS.md`):

- bundle exec rubocop
- bundle exec brakeman
- bundle exec bundler-audit check --update
- bundle exec rspec
- bin/ui-screenshots

UI evidence:

- tmp/screenshots/ui/contracts/default_active_year (desktop, iPad, iPhone)
- tmp/screenshots/ui/contracts/filtered_next_year (desktop, iPad, iPhone)
- tmp/screenshots/ui/contracts/filtered_all (desktop, iPad, iPhone)

Acceptance:
- New behavior works in browser.
- Required tests pass (or pre-existing failures are documented as out of scope).
- Screenshots exist under expected paths.
- Logs updated with evidence.

## Idempotence and Recovery

- Migrations reversible.
- Imports safe to retry (no partial inserts on error).
- Saved views safe to apply repeatedly.

## Artifacts and Notes

Include concise terminal transcripts and key diffs as indented blocks.
