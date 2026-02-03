# Iteration 5C: Visualization upgrades (Cost Hub + Contracts)

This ExecPlan is a living document. The sections **Progress**, **Surprises & Discoveries**, **Decision Log**, and **Outcomes & Retrospective** must be kept up to date as work proceeds.

If `.agent/PLANS.md` exists in this repository, this plan must be maintained in accordance with it. citeturn0search1

## Purpose / Big Picture

Add richer visualization tools to Cost Hub and Contracts while keeping charts deterministic for screenshot tests.

## Progress

- [x] (2026-02-03 17:00) Read `AGENTS.md` and confirmed required commands and screenshot expectations.
- [x] (2026-02-03 17:20) Complete Milestone 1.
- [x] (2026-02-03 17:30) Complete Milestone 2.
- [x] (2026-02-03 17:40) Complete Milestone 3.
- [x] (2026-02-03 17:45) Final validation: run required commands, attempted screenshots, updated logs.

## Surprises & Discoveries

- Observation: Cost per unit trends needed delivery unit counts by date.
  Evidence: app/controllers/cost_entries_controller.rb.

## Decision Log

- Decision: Add cost composition and cost per unit charts using existing Chart.js setup.
  Rationale: Avoided new dependencies and kept charts deterministic.
  Date/Author: 2026-02-03 Codex

## Outcomes & Retrospective

- Outcome: Cost Hub and Contract visualizations expanded with summary panels and tests.
  Gaps: UI screenshots are pending due to missing Chrome.
  Lessons learned: Keep chart containers fixed height to improve mobile stability.

## Context and Orientation

This plan assumes a Rails app with Devise authentication and system specs using Capybara. Navigation uses a shared sidebar partial. The codebase already contains Programs, Contracts, a Cost Hub, and Import flows.

**Important constraint (to avoid Codex PR errors):** keep PRs text-only whenever possible. Avoid committing binary assets (for example `.xlsx`, `.png`, `.ico`). Prefer dynamic template generation for XLSX downloads rather than committing static templates. citeturn0search1



## Scope

- Add cost composition and cost-per-unit trend charts in Cost Hub.
- Add contracts summary charts and an export-ready summary section.
- Stabilize chart containers for iPhone.

## Plan of Work

### Milestone 1 - Cost Hub charts

Add 2 new charts and validate aggregation with unit tests.

### Milestone 2 - Contracts charts

Add summary charts/panels and system tests.

### Milestone 3 - Screenshot stability

Fix container sizes and responsive behavior.


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

- tmp/screenshots/ui/cost_hub/visualizations (desktop, iPad, iPhone)
- tmp/screenshots/ui/contracts/summary_charts (desktop, iPad)

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
