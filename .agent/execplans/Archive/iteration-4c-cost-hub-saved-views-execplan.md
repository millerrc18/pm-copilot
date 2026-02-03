# Iteration 4C: Cost Hub saved views + visualization polish

This ExecPlan is a living document. The sections **Progress**, **Surprises & Discoveries**, **Decision Log**, and **Outcomes & Retrospective** must be kept up to date as work proceeds.

If `.agent/PLANS.md` exists in this repository, this plan must be maintained in accordance with it. citeturn0search1

## Purpose / Big Picture

Allow users to save preferred Cost Hub filters (program, date range, period type if applicable) and improve visualization layout behavior across iPhone/iPad/desktop.

## Progress

- [x] (2026-02-01 21:30) Read `.agent/AGENTS.md` and confirm required commands and screenshot expectations.
- [x] (2026-02-01 21:30) Complete Milestone 1.
- [x] (2026-02-01 21:30) Complete Milestone 2.
- [x] (2026-02-01 21:30) Complete Milestone 3.
- [x] (2026-02-01 21:30) Final validation: run all required commands; capture screenshots; update logs; prepare PR.

## Surprises & Discoveries

- Observation: Chrome was not available in the environment, so ui-screenshots and screenshot specs remained pending.
  Evidence: bin/ui-screenshots output reporting missing Chrome.

## Decision Log

- Decision: Store Cost Hub saved filters in a per user JSON column and manage updates via a dedicated controller.
  Rationale: Keeps the saved view logic scoped to the user account and avoids coupling with CostEntry CRUD.
  Date/Author: 2026-02-01 Codex

## Outcomes & Retrospective

- Outcome: Cost Hub filters now persist per user with Save and Reset controls, and chart layout sizing is tighter for small viewports.
  Gaps: UI screenshots remain pending because Chrome is unavailable.
  Lessons learned: Keep saved view actions independent from filter application so defaults are explicit.

## Context and Orientation

This plan assumes a Rails app with Devise authentication and system specs using Capybara. Navigation uses a shared sidebar partial. The codebase already contains Programs, Contracts, a Cost Hub, and Import flows.

**Important constraint (to avoid Codex PR errors):** keep PRs text-only whenever possible. Avoid committing binary assets (for example `.xlsx`, `.png`, `.ico`). Prefer dynamic template generation for XLSX downloads rather than committing static templates. citeturn0search1



## Scope

- Persist filter state per user and apply on load.
- Add Save as default and Reset controls.
- Ensure charts/KPIs remain readable and do not overflow on iPhone widths.

## Plan of Work

### Milestone 1 - Persisted filters

Store Cost Hub filter params per user. Default to saved view or sensible defaults.

### Milestone 2 - UX controls and tests

Add Save/Reset controls and system tests proving persistence across reload.

### Milestone 3 - Visualization polish

Stabilize chart containers, labels, legends for Apple viewports. Add minimal additional KPI if low risk.


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

- tmp/screenshots/ui/cost_hub/default (desktop, iPad, iPhone)
- tmp/screenshots/ui/cost_hub/saved_view_applied (desktop, iPad, iPhone)

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
