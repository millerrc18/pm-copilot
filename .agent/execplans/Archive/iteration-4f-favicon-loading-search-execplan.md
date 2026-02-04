# Iteration 4F: Favicon + loading luxuries + cross-platform search keytips

This ExecPlan is a living document. The sections **Progress**, **Surprises & Discoveries**, **Decision Log**, and **Outcomes & Retrospective** must be kept up to date as work proceeds.

If `.agent/PLANS.md` exists in this repository, this plan must be maintained in accordance with it. citeturn0search1

## Purpose / Big Picture

Add favicon support (prefer SVG), add a sleek loading spinner/progress styling, and fix search keytips to be correct for Mac and Windows.

## Progress

- [x] (2026-02-02 17:00) Read `.agent/AGENTS.md` and confirm required commands and screenshot expectations.
- [x] (2026-02-02 17:10) Complete Milestone 1.
- [x] (2026-02-02 17:20) Complete Milestone 2.
- [x] (2026-02-02 17:30) Complete Milestone 3.
- [x] (2026-02-02 17:45) Final validation: run all required commands; capture screenshots; update logs; prepare PR.

## Surprises & Discoveries

- Observation: Chrome was not available for UI screenshot capture.
  Evidence: docs/quality/issue_log.md ISS-013.

## Decision Log

- Decision: Use the existing icon source to generate an SVG favicon.
  Rationale: Avoided committing new binary assets while meeting the favicon requirement.
  Date/Author: 2026-02-02 Codex

## Outcomes & Retrospective

- Outcome: Added favicon link tags, loading visuals, and corrected search keytips.
  Gaps: UI screenshots pending due to missing Chrome.
  Lessons learned: Keep asset generation scripts idempotent for repeatable builds.

## Context and Orientation

This plan assumes a Rails app with Devise authentication and system specs using Capybara. Navigation uses a shared sidebar partial. The codebase already contains Programs, Contracts, a Cost Hub, and Import flows.

**Important constraint (to avoid Codex PR errors):** keep PRs text-only whenever possible. Avoid committing binary assets (for example `.xlsx`, `.png`, `.ico`). Prefer dynamic template generation for XLSX downloads rather than committing static templates. citeturn0search1



## Scope

- Prefer SVG favicon (text) and avoid committing binary icons when possible.
- Style Turbo progress bar and add global spinner on navigations/forms.
- Show ⌘K on macOS and Ctrl+K on Windows/Linux; or show both if preferred.

## Plan of Work

### Milestone 1 - Favicon

Add favicon tags in layout. Prefer an SVG favicon committed as text.

### Milestone 2 - Loading luxuries

Style Turbo progress bar using theme variables and add a global spinner tied to navigation/form submission state. Respect prefers-reduced-motion.

### Milestone 3 - Search keytips

Update keytips to reflect platform or show dual hint. Add a light test where feasible.


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

- tmp/screenshots/ui/nav/search_keytips (desktop)
- tmp/screenshots/ui/nav/loading_indicator (desktop)

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
