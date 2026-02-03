# Iteration 5B: Planning Hub timeline (contracts, milestones, units)

This ExecPlan is a living document. The sections **Progress**, **Surprises & Discoveries**, **Decision Log**, and **Outcomes & Retrospective** must be kept up to date as work proceeds.

If `.agent/PLANS.md` exists in this repository, this plan must be maintained in accordance with it. citeturn0search1

## Purpose / Big Picture

Provide a Planning Hub timeline that aggregates contract periods, milestones and delivery units with filters and safe edit workflows.

## Progress

- [x] (2026-02-03 17:00) Read `AGENTS.md` and confirmed required commands and screenshot expectations.
- [x] (2026-02-03 17:15) Complete Milestone 1.
- [x] (2026-02-03 17:25) Complete Milestone 2.
- [x] (2026-02-03 17:35) Complete Milestone 3.
- [x] (2026-02-03 17:45) Final validation: run required commands, attempted screenshots, updated logs.

## Surprises & Discoveries

- Observation: Modal edits required a safe return path back to the Planning Hub.
  Evidence: app/controllers/contracts_controller.rb, app/controllers/delivery_milestones_controller.rb, app/controllers/delivery_units_controller.rb.

## Decision Log

- Decision: Use dialog based modal forms with a return_to parameter for updates.
  Rationale: Keeps edits in context without changing existing CRUD flows.
  Date/Author: 2026-02-03 Codex

## Outcomes & Retrospective

- Outcome: Planning Hub timeline and modal edit workflows implemented with tests.
  Gaps: UI screenshots are pending due to missing Chrome.
  Lessons learned: Return paths are needed when adding modal edits to existing controllers.

## Context and Orientation

This plan assumes a Rails app with Devise authentication and system specs using Capybara. Navigation uses a shared sidebar partial. The codebase already contains Programs, Contracts, a Cost Hub, and Import flows.

**Important constraint (to avoid Codex PR errors):** keep PRs text-only whenever possible. Avoid committing binary assets (for example `.xlsx`, `.png`, `.ico`). Prefer dynamic template generation for XLSX downloads rather than committing static templates. citeturn0search1



## Scope

- Add Planning Hub page under Workspace.
- Timeline view optimized for desktop/iPad with simplified iPhone view.
- Edit via modal forms (avoid drag-drop as first cut).

## Plan of Work

### Milestone 1 - Aggregation service

Convert records into timeline items. Unit test.

### Milestone 2 - Timeline UI

Render timeline and filters; responsive behavior.

### Milestone 3 - Editing

Add edit modals and system tests.


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

- tmp/screenshots/ui/planning_hub/index (desktop, iPad, iPhone)
- tmp/screenshots/ui/planning_hub/edit_modal (desktop, iPad)

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
