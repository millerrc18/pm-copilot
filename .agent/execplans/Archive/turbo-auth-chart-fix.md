# Fix Turbo auth flow, progress bar config, and Chart.js importmap

This ExecPlan is a living document. The sections Progress, Surprises & Discoveries, Decision Log, and Outcomes & Retrospective must be kept up to date as work proceeds.

This repository includes .agent/PLANS.md at the repository root. This ExecPlan must be maintained in accordance with that document.

## Purpose / Big Picture

Users should be able to sign in or sign up on corporate networks without Turbo fetch failures, see no Turbo deprecation warnings for progress bar configuration, and load chart pages without importmap module errors. The result is visible by visiting Devise auth pages, observing no Turbo fetch failures on blocked redirects, and opening chart pages without JavaScript module errors.

## Progress

- [x] Capture baseline context and update this plan with any discoveries.
- [x] Update Turbo progress bar configuration to use Turbo.config.drive.progressBarDelay.
- [x] Disable Turbo Drive on all Devise forms and add system coverage for data-turbo attributes.
- [x] Fix Chart.js importmap pins and controller import, then add system coverage for chart page rendering.
- [x] Update UI screenshot coverage for auth and chart pages, update quality logs, and update AGENTS.md troubleshooting notes.
- [x] Run required validation commands and capture evidence.
- [x] Summarize outcomes and record retrospective.

## Surprises & Discoveries

- Cuprite could not find a Chromium binary, so JavaScript system specs and UI screenshots were skipped or failed with missing browser errors during validation.

## Decision Log

- Decision: Start with targeted configuration and view changes, then tests and screenshot updates, then documentation and logs.
  Rationale: The instructions require small commits and verification for each change group.
  Date/Author: 2026-02-06 / Codex

## Outcomes & Retrospective

Turbo progress bar configuration now uses the supported configuration API, Devise forms disable Turbo Drive to avoid fetch failures on external redirects, and Chart.js importmap pins include chart.js/auto and @kurkle/color. System coverage and screenshot automation were updated, with validation limited by missing Chrome.

## Context and Orientation

The app uses Turbo and Devise for authentication, with importmap managing JavaScript dependencies. Chart rendering is driven by a Stimulus controller in app/javascript/controllers/chart_controller.js and pinned dependencies in config/importmap.rb. System tests use Capybara and Cuprite, and screenshot automation lives in spec/system/ui_responsive_screenshots_spec.rb.

## Plan of Work

Update app/javascript/application.js to use Turbo.config.drive.progressBarDelay. Update Devise form views under app/views/devise to disable Turbo via data-turbo attributes. Adjust config/importmap.rb to pin chart.js/auto and @kurkle/color and update chart_controller.js to import from chart.js/auto. Add or update system specs to verify auth forms include data-turbo="false" and chart pages render under a JavaScript driver. Extend UI screenshot coverage for auth and chart pages with deterministic paths. Update AGENTS.md troubleshooting notes and update docs/quality/issue_log.md and docs/quality/improvement_log.md with evidence. Run required test commands and screenshot capture.

## Concrete Steps

From the repository root, run:

  - bundle install
  - RAILS_ENV=test bin/rails db:prepare
  - Edit app/javascript/application.js to update Turbo config.
  - Edit app/views/devise/* form views to add data-turbo="false".
  - Edit config/importmap.rb and app/javascript/controllers/chart_controller.js for Chart.js pins and imports.
  - Add or update spec/system coverage for auth and chart pages.
  - Update spec/system/ui_responsive_screenshots_spec.rb for new screenshot targets.
  - Update AGENTS.md and docs/quality logs.

## Validation and Acceptance

Run required commands:

  - bundle exec rubocop
  - bundle exec brakeman
  - bundle exec bundler-audit check --update
  - bundle exec rspec
  - bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/cost_hub_import_spec.rb spec/system/navigation_spec.rb spec/system/navigation_routes_spec.rb spec/system/account_management_spec.rb
  - bin/ui-screenshots

Acceptance is met when Devise forms contain data-turbo="false", Turbo deprecation warnings are gone, chart pages load without module errors, tests pass, and screenshots are generated under tmp/screenshots/ui.

## Idempotence and Recovery

If edits fail or tests fail, revert via git checkout for the impacted files and reapply changes. Rerun bin/ui-screenshots after ensuring FERRUM_BROWSER_PATH points to a valid Chromium binary. Re-run tests until they pass.

## Artifacts and Notes

Record test outputs and screenshot paths in the quality logs and final summary.

## Interfaces and Dependencies

Turbo configuration lives in app/javascript/application.js. Devise form views are in app/views/devise. Chart.js is managed through importmap in config/importmap.rb and used in app/javascript/controllers/chart_controller.js. System tests run with Capybara and Cuprite.
