# Iteration 4A: Unified Imports Hub (Costs, Milestones, Delivery Units)

This ExecPlan is a living document. The sections **Progress**, **Surprises & Discoveries**, **Decision Log**, and **Outcomes & Retrospective** must be kept up to date as work proceeds.

If `.agent/PLANS.md` exists in this repository, this plan must be maintained in accordance with it. citeturn0search1

## Purpose / Big Picture

Deliver a single Imports Hub page with tabs for Costs, Milestones and Delivery Units. Users can download templates (generated dynamically), upload XLSX files, see row-level validation errors, and create records scoped correctly (costs scoped to Program; milestones/units validated to Program via contracts).

## Progress

- [ ] (YYYY-MM-DD HH:MM) Read `.agent/AGENTS.md` and confirm required commands and screenshot expectations.
- [ ] (YYYY-MM-DD HH:MM) Complete Milestone 1.
- [ ] (YYYY-MM-DD HH:MM) Complete Milestone 2.
- [ ] (YYYY-MM-DD HH:MM) Complete Milestone 3.
- [ ] (YYYY-MM-DD HH:MM) Final validation: run all required commands; capture screenshots; update logs; prepare PR.

## Surprises & Discoveries

- Observation:  
  Evidence:  

## Decision Log

- Decision:  
  Rationale:  
  Date/Author:  

## Outcomes & Retrospective

- Outcome:  
  Gaps:  
  Lessons learned:  

## Context and Orientation

This plan assumes a Rails app with Devise authentication and system specs using Capybara. Navigation uses a shared sidebar partial. The codebase already contains Programs, Contracts, a Cost Hub, and Import flows.

**Important constraint (to avoid Codex PR errors):** keep PRs text-only whenever possible. Avoid committing binary assets (for example `.xlsx`, `.png`, `.ico`). Prefer dynamic template generation for XLSX downloads rather than committing static templates. citeturn0search1



## Scope

- Move/confirm navigation: Cost Hub under Workspace; Imports under Imports; Imports Hub is the entry point for all importing.
- Dynamic template downloads for XLSX to avoid committing binaries.
- All-or-nothing imports by default with row-level error reporting.
- Fix dark theme dropdown readability (program dropdown contrast).

## Plan of Work

### Milestone 1 - Imports Hub IA and navigation

Add an Imports hub route/controller and tabbed page. Keep Cost Hub under Workspace and keep importing under Imports.

### Milestone 2 - Dynamic template downloads

Add endpoints that generate XLSX templates at request time (Costs, Milestones, Delivery Units). Add request specs verifying headers and non-empty content.

### Milestone 3 - Import services with validations

Implement services for Milestones and Delivery Units imports validating contract_code belongs to selected Program and enforcing all-or-nothing inserts. Add system specs for valid/invalid uploads.


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

- tmp/screenshots/ui/imports/costs (desktop, iPad, iPhone)
- tmp/screenshots/ui/imports/milestones (desktop, iPad, iPhone)
- tmp/screenshots/ui/imports/delivery_units (desktop, iPad, iPhone)

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

