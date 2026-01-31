# AGENTS.md

## Project rules
- Do not use em dashes in any text output or docs.
- Do not introduce or store real credentials. Use seeds or test fixtures only.
- Keep tasks small and verifiable. If the scope is large, propose a 3–7 step plan first.

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

## Tests (must run after changes)
- bundle exec rubocop
- bundle exec brakeman
- bundle exec bundler-audit check --update
- bundle exec rspec
- bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/navigation_spec.rb
- bin/ui-screenshots

## UI screenshots (required for UI work)
### Required pages
- Cost Hub page
- Import Costs page
- Programs index page (smoke check that global layout is sane)

### Required viewports
- Desktop: 1440x900
- iPad: 834x1194
- iPhone: 393x852

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
