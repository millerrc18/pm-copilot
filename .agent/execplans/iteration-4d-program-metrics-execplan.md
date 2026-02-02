# Iteration 4D: Program page metrics (Profit, ROS, ROC)

This ExecPlan is a living document. The sections **Progress**, **Surprises & Discoveries**, **Decision Log**, and **Outcomes & Retrospective** must be kept up to date as work proceeds.

If `.agent/PLANS.md` exists in this repository, this plan must be maintained in accordance with it. citeturn0search1

## Purpose / Big Picture

Add Profit, Return on Sales (ROS), and Return on Cost (ROC) to Program pages using program-scoped totals with correct edge-case handling.

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

- Compute Profit = Revenue - Cost; ROS = Profit/Revenue; ROC = Profit/Cost.
- Show N/A when denominator is zero and explain with tooltip definitions.
- Add unit tests and a system test verifying rendered output.

## Plan of Work

### Milestone 1 - Computation and unit tests

Implement methods/presenter for Profit/ROS/ROC. Unit test normal and zero-denominator cases.

### Milestone 2 - Program UI

Render KPI cards with tooltips and consistent formatting across themes.

### Milestone 3 - System test

Create system spec that seeds data and verifies displayed metrics.


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

- tmp/screenshots/ui/programs/metrics (desktop, iPad, iPhone)

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

