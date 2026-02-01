# PM Copilot - AGENTS.md

This file provides project guidance for coding agents (Codex, Copilot, Cursor, etc).
Codex reads AGENTS.md before doing work and may also read nested AGENTS.md files depending on where it is invoked. See discovery notes below.

## Project rules
- Do not use em dashes in any text output or docs.
- Do not introduce or store real credentials. Use seeds or test fixtures only.
- Keep tasks small and verifiable. If the scope is large, propose a 3–7 step plan first.
- If the prompt references an iteration ExecPlan, follow it verbatim, update its Progress/Decision Log/Surprises, and commit in small steps.
- Some platforms and agent flows fail when binary files are included in PR content.

# ExecPlans
When writing complex features or significant refactors, use an ExecPlan (as described in .agent/PLANS.md) from design to implementation.
ExecPlans live in: `.agent/execplans/`

## Local setup (Codex must follow)
- bundle install
- RAILS_ENV=test bin/rails db:prepare

## System test driver
- System tests use Capybara + Cuprite, not Selenium.
- Chromium must be available. If the environment cannot find it, set FERRUM_BROWSER_PATH and document the path.

## Definition of done for any change
- Update or add tests for the change (model/service specs when applicable).
- For any UI change, update system tests and capture screenshots (see below).
- Run all validation commands in the Tests section and report pass/fail.

## Quality logs

Maintain these logs during each iteration:
- `docs/quality/issue_log.md` (bugs and defects observed during inspection/testing)
- `docs/quality/improvement_log.md` (polish ideas, UX improvements, future enhancements)

For each meaningful change:
- add an entry with: date, page/area, what changed, why, and evidence (test output or screenshot path)

## Environment and credentials for UI system tests

Do not hardcode credentials in the repository.

UI login credentials must be provided via environment variables:
- `UI_TEST_EMAIL`
- `UI_TEST_PASSWORD`

System tests and `bin/ui-screenshots` should read from these env vars.

## Tests (must run after changes)
- bundle exec rubocop
- bundle exec brakeman
- bundle exec bundler-audit check --update
- bundle exec rspec
- bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/cost_hub_import_spec.rb spec/system/navigation_spec.rb spec/system/navigation_routes_spec.rb spec/system/account_management_spec.rb
- bin/ui-screenshots

## UI screenshots (required for UI work)
### Required pages
- Cost Hub
- Imports Hub (Costs, Milestones, Delivery Units)
- Contracts
- Programs
- Account/Profile
- Knowledge Center

### Required viewports
- iPhone: 390x844 (or closest available in your driver config)
- iPad: 820x1180 (or closest available)
- Desktop: 1440x900 (or closest available)

### Output locations (deterministic)
- tmp/screenshots/ui/cost_hub/<viewport>__closed.png
- tmp/screenshots/ui/cost_imports/<viewport>__closed.png
- tmp/screenshots/ui/programs/<viewport>__closed.png

If a mobile drawer exists:
- tmp/screenshots/ui/<page>/<viewport>__open.png for iPhone and iPad

### Verification
- Ensure screenshots are saved under tmp/screenshots/ui/...
- Ensure tmp/screenshots/ui is in .gitignore
- Do not commit screenshots

## Notes for Codex prompts
- Treat each prompt like a GitHub issue: context, expected behavior, acceptance criteria, and validation steps.

## Codex discovery notes (for reliability)

Codex builds an instruction chain when it starts:
- Global scope files in the Codex home directory may apply first
- Then project scope files are discovered from the repo root down to the working directory

This means:
- Keep this `AGENTS.md` at repo root
- If needed, add nested AGENTS.md files only for subprojects with special commands
