# CI system tests and local JS spec gating

This ExecPlan is a living document. The sections Progress, Surprises & Discoveries, Decision Log, and Outcomes & Retrospective must be kept up to date as work proceeds.

This plan follows .agent/PLANS.md from the repository root and must be maintained in accordance with it.

## Purpose / Big Picture

Ensure system and JS specs are reliable in CI with Chrome available, and stop local runs from failing when Chrome is missing. Ensure Tailwind builds before specs so assets exist. Users should be able to run the default spec suite locally without Chrome, while CI runs the full suite including JS system tests.

## Progress

- [x] Review current spec and Capybara setup to decide where to tag JS specs and how to exclude them locally.
- [x] Ensure Tailwind build runs before specs and confirm builds output to app/assets/builds/tailwind.css.
- [x] Add CI workflow for full rspec with Chrome setup and Tailwind build.
- [x] Update RSpec configuration to exclude JS specs locally and include them in CI.
- [x] Update quality logs with evidence.
- [x] Run required commands and capture results.

## Surprises & Discoveries

- bundle install failed because the draft_generators Git dependency returned a GitHub 500 error.
- bundler-audit failed to update the advisory database due to a GitHub 500 error.
- bundle exec rspec still reports a failure in ops_imports_spec due to job_id mismatch.

## Decision Log

- Decision: Use js tagged specs to gate Chrome dependent tests and add CI to run full suite with tag js.
  Rationale: Keeps local developer runs from failing when Chrome is missing while ensuring CI coverage.
  Date/Author: 2026-02-15 / Codex

## Outcomes & Retrospective

Local runs now exclude JS specs by default, the Tailwind build is wired to the spec task, and CI is set to install Chrome and run JS specs separately. The remaining rspec failure is unrelated to the JS gating changes and should be addressed in a separate fix.

## Context and Orientation

System specs use Capybara with Cuprite and currently fail locally because Chrome is missing. The asset pipeline uses Tailwind CSS builds in app/assets/builds, but tailwind.css is not built before tests. The task requires adding a CI workflow to install Chrome, prepare the database, build Tailwind, and run full specs.

## Plan of Work

First, inspect the spec and Capybara setup to identify JS system tests and how to tag them. Add js: true to system specs or shared support as needed. Update .rspec to exclude js tagged specs by default and add a CI workflow to run rspec with tag js. Add a Rake dependency so the spec task triggers tailwindcss:build, and confirm app/assets/builds/.keep exists and is committed. Update docs/quality logs with the changes and test evidence.

## Concrete Steps

Run these commands from /workspace/pm-copilot:

  - rg "type: :system" -n spec
  - ls app/assets/builds
  - bundle exec rubocop
  - bundle exec brakeman
  - bundle exec bundler-audit check --update
  - bundle exec rspec
  - bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/cost_hub_import_spec.rb spec/system/navigation_spec.rb spec/system/navigation_routes_spec.rb spec/system/account_management_spec.rb
  - bin/ui-screenshots

## Validation and Acceptance

Tailwind builds before specs so tailwind.css exists and asset errors are resolved. Local spec runs skip js tagged specs by default and do not require Chrome. CI workflow installs Chrome and runs rspec with js tagged specs included. Quality logs document the change and evidence.

## Idempotence and Recovery

Re-running the Tailwind build or rspec should be safe. If CI fails, rerun the workflow and inspect the logs. To rollback, remove the workflow file and restore the previous RSpec and Rake configuration.

## Artifacts and Notes

Record workflow file path and test outputs in the quality logs.

## Interfaces and Dependencies

Use Rails tailwindcss:build task for asset generation, RSpec tag filtering with js tag, and browser-actions/setup-chrome@v2 in GitHub Actions.
