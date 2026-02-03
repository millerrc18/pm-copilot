# Iteration 5E: Knowledge Center restructure + search + contextual help

This ExecPlan is a living document. The sections **Progress**, **Surprises & Discoveries**, **Decision Log**, and **Outcomes & Retrospective** must be kept up to date as work proceeds.

If `.agent/PLANS.md` exists in this repository, this plan must be maintained in accordance with it. citeturn0search1

## Purpose / Big Picture

Improve documentation usability by restructuring Knowledge Center, adding search, and adding contextual help links from core pages.

## Progress

- [x] (2026-02-03 17:00) Read `AGENTS.md` and confirmed required commands and screenshot expectations.
- [x] (2026-02-03 17:25) Complete Milestone 1.
- [x] (2026-02-03 17:35) Complete Milestone 2.
- [x] (2026-02-03 17:40) Complete Milestone 3.
- [x] (2026-02-03 17:45) Final validation: run required commands, attempted screenshots, updated logs.

## Surprises & Discoveries

- Observation: Global search used case sensitive ILIKE and required cross database adjustments.
  Evidence: app/controllers/search_controller.rb.

## Decision Log

- Decision: Rank Knowledge Center results by title, summary, and content matches.
  Rationale: Provides consistent ordering without adding a full text search dependency.
  Date/Author: 2026-02-03 Codex

## Outcomes & Retrospective

- Outcome: Knowledge Center categories refreshed with ranked search and contextual help links.
  Gaps: UI screenshots are pending due to missing Chrome.
  Lessons learned: Contextual help links reduce navigation confusion for new pages.

## Context and Orientation

This plan assumes a Rails app with Devise authentication and system specs using Capybara. Navigation uses a shared sidebar partial. The codebase already contains Programs, Contracts, a Cost Hub, and Import flows.

**Important constraint (to avoid Codex PR errors):** keep PRs text-only whenever possible. Avoid committing binary assets (for example `.xlsx`, `.png`, `.ico`). Prefer dynamic template generation for XLSX downloads rather than committing static templates. citeturn0search1



## Scope

- Ensure naming does not conflict with Contracts.
- Add searchable documentation index and results page.
- Add contextual help links/tooltips on hubs.

## Plan of Work

### Milestone 1 - IA restructure

Categories, navigation, and consistent naming.

### Milestone 2 - Search

Title/excerpt search and tests.

### Milestone 3 - Contextual help

Deep links from hubs and system tests.


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

- tmp/screenshots/ui/knowledge_center/index (desktop, iPad, iPhone)
- tmp/screenshots/ui/knowledge_center/search_results (desktop, iPad)

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
