# Add favicon, loading indicator, and search keytips

This ExecPlan is a living document. The sections Progress, Surprises and Discoveries, Decision Log, and Outcomes and Retrospective must be kept up to date as work proceeds.

This plan follows .agent/PLANS.md from the repository root and must be maintained in accordance with it.

## Purpose / Big Picture

Users should see the new favicon in the browser, a polished Turbo progress bar and global loading indicator during navigation or form submissions, and search keytips that show both Ctrl K and Command K. We will confirm the favicon link tags in layout specs, update styles for Turbo progress and the loading overlay, and adjust the search keytips rendering. We will record evidence in quality logs and run the required test commands.

## Progress

- [x] Review current layout, search keytips, and styles to locate changes.
- [x] Add favicon SVG generator script and generated SVG asset.
- [x] Update layout head to include favicon link tags.
- [x] Add Turbo progress bar and global loading indicator styles, plus markup.
- [x] Update search keytips to show Ctrl and Command.
- [x] Add or update specs for favicon and keytips.
- [x] Update quality logs and run required validations.
- [x] Commit changes and prepare PR message.

## Surprises and Discoveries

Development database preparation failed because a migration added a foreign key to cost_entries before that table existed, so the browser screenshot used the test environment instead.

## Decision Log

- Decision: Use public/icon.png as the source image for the SVG wrapped favicon to avoid introducing a new binary file.
  Rationale: The repository already includes this asset and the instructions allow reading a provided image while avoiding new binary commits.
  Date/Author: 2025-02-07 / Codex

- Decision: Capture the browser screenshot against the test environment because the development database could not migrate cleanly.
  Rationale: Test database preparation succeeded and allowed a rendered page for the required screenshot.
  Date/Author: 2026-02-02 / Codex

## Outcomes and Retrospective

Delivered favicon SVG, Turbo loading visuals, and cross platform keytips with request and view specs. Validation commands ran with pending system coverage due to missing Chrome.

## Context and Orientation

The layout lives in app/views/layouts/application.html.erb. Styling is likely in app/assets/stylesheets or tailwind files. Search keytips are likely in a shared header or navigation partial. Specs live under spec. Quality logs live under docs/quality/.

## Plan of Work

First, locate the layout head, search keytips partial, and existing styles for Turbo and navigation. Next, add bin/generate_favicon_svg to wrap public/icon.png into app/assets/images/favicon.svg and run it once to generate the SVG. Update the layout head to include favicon link tags using Rails helpers. Then add markup for a global loading overlay near the end of the body and add CSS to show it when html aria-busy is true and to style the Turbo progress bar. Update keytips to show Ctrl K and Command K together. Add specs to assert the favicon link tag and keytips. Update issue and improvement logs with evidence placeholders. Finally, run the required validation commands, capture results, commit, and create the PR message.

## Concrete Steps

Run commands from the repository root. First inspect files with rg and sed. Add the generator script and run it to create app/assets/images/favicon.svg. Edit layout, styles, and partials. Add specs. Update logs. Run bundle exec rubocop, bundle exec brakeman, bundle exec bundler-audit check --update, RAILS_ENV=test bin/rails db:prepare, RAILS_ENV=test bin/rails tailwindcss:build if applicable, bundle exec rspec, and the focused rspec set. Run bin/ui-screenshots if possible, otherwise document why it could not run.

## Validation and Acceptance

The layout should render a link rel icon to favicon.svg. The Turbo progress bar should be styled via CSS. The global loading overlay should appear when html aria-busy is true. The search keytips should show both Ctrl K and Command K. Specs should pass. Validation commands should be reported with pass or fail in the final summary.

## Idempotence and Recovery

The generator script can be rerun to refresh favicon.svg. If tests fail, fix issues and rerun the same commands. If bin/ui-screenshots fails due to missing Chrome, record the failure in docs/quality/issue_log.md and report it.

## Artifacts and Notes

Record test outputs and any screenshot paths in docs/quality logs. Include evidence references.

## Interfaces and Dependencies

Use Rails favicon_link_tag for the layout, Turbo progress bar styling via .turbo-progress-bar, and HTML aria-busy toggling for the loading overlay. Use standard Rails request or view specs to verify rendered HTML.
