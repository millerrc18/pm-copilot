# Iteration 5A: Risk and Opportunity tracker (CRUD + scoring + summary)

This ExecPlan is a living document. The sections **Progress**, **Surprises & Discoveries**, **Decision Log**, and **Outcomes & Retrospective** must be kept up to date as work proceeds.

If `.agent/PLANS.md` exists in this repository, this plan must be maintained in accordance with it. citeturn0search1

## Purpose / Big Picture

Deliver a Risk/Opportunity register with CRUD, scoring, filters and summary widgets on Program/Contract pages.

## Progress

- [x] (2026-02-03 17:00) Read `AGENTS.md` and confirmed required commands and screenshot expectations.
- [x] (2026-02-03 17:10) Complete Milestone 1.
- [x] (2026-02-03 17:20) Complete Milestone 2.
- [x] (2026-02-03 17:30) Complete Milestone 3.
- [x] (2026-02-03 17:45) Final validation: run required commands, attempted screenshots, updated logs.

## Surprises & Discoveries

- Observation: Risk register links conflicted with doc links in navigation specs and required disambiguation.
  Evidence: spec/system/navigation_routes_spec.rb.

## Decision Log

- Decision: Enforce program or contract scoping with a single Risk model and summary panels on program and contract pages.
  Rationale: Keeps ownership aligned with existing scoping and avoids duplicate models.
  Date/Author: 2026-02-03 Codex

## Outcomes & Retrospective

- Outcome: Risk register CRUD, summary widgets, and exports implemented with tests.
  Gaps: UI screenshots are pending due to missing Chrome.
  Lessons learned: System specs should target main content to avoid sidebar collisions.

## Context and Orientation

This plan assumes a Rails app with Devise authentication and system specs using Capybara. Navigation uses a shared sidebar partial. The codebase already contains Programs, Contracts, a Cost Hub, and Import flows.

**Important constraint (to avoid Codex PR errors):** keep PRs text-only whenever possible. Avoid committing binary assets (for example `.xlsx`, `.png`, `.ico`). Prefer dynamic template generation for XLSX downloads rather than committing static templates. citeturn0search1



## Scope

- Risk model with type (risk/opportunity), probability, impact, severity, status, owner, due date.
- Strict association validation: exactly one of program or contract set.
- Register page with filters and summary widgets.

## Plan of Work

### Milestone 1 - Model and validations

Create Risk model and severity computation. Unit test edge cases.

### Milestone 2 - CRUD UI and register filters

Index/new/edit views with filters and status updates.

### Milestone 3 - System tests and screenshots

System spec to create/edit items and verify severity/status; capture screenshots.


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

- tmp/screenshots/ui/risks/index (desktop, iPad, iPhone)
- tmp/screenshots/ui/programs/risk_widgets (desktop, iPad)

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
