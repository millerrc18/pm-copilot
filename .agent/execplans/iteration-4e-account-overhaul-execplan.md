# Iteration 4E: Account page overhaul (profile, avatar, stats, 3 themes)

This ExecPlan is a living document. The sections **Progress**, **Surprises & Discoveries**, **Decision Log**, and **Outcomes & Retrospective** must be kept up to date as work proceeds.

If `.agent/PLANS.md` exists in this repository, this plan must be maintained in accordance with it. citeturn0search1

## Purpose / Big Picture

Rebuild the account page into a user profile center with avatar upload, lifetime stats, and a simple 3-option theme selector (dark/coral, dark/blue, light).

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

- Avatar upload via Active Storage with validations.
- Lifetime stats panel (counts and totals) derived from user-visible data.
- Theme selection persisted per user and applied site-wide via CSS variables.

## Plan of Work

### Milestone 1 - Data and storage

Add theme preference field and profile fields if missing. Ensure Active Storage configured for avatar.

### Milestone 2 - UI rebuild

Implement profile layout: header (avatar/name), profile details, lifetime stats, theme selection cards.

### Milestone 3 - Theme application and tests

Implement CSS variables for themes and ensure persistence. Add system tests for avatar and theme persistence.


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

- tmp/screenshots/ui/account/dark-coral (desktop, iPad, iPhone)
- tmp/screenshots/ui/account/dark-blue (desktop, iPad, iPhone)
- tmp/screenshots/ui/account/light (desktop, iPad, iPhone)

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

