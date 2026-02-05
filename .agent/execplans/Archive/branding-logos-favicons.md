# Wire new branding logos and favicons

This ExecPlan is a living document. The sections Progress, Surprises and Discoveries, Decision Log, and Outcomes and Retrospective must be kept up to date as work proceeds.

This plan follows .agent/PLANS.md from the repository root and must be maintained in accordance with it.

## Purpose / Big Picture

Users should see the new PM Copilot branding in navigation, auth pages, and browser icons. After this change, the sidebar and auth pages show the correct logo for light and dark themes, the browser tab uses light and dark favicons with a fallback, and an apple touch icon link is present. A reader can verify by visiting the app pages and checking the head tags.

## Progress

- [x] Review branding assets and confirm naming and sizes.
- [x] Add shared brand logo partial with theme based switching and use it in navigation and auth views.
- [x] Add favicon and apple touch icon links in layouts.
- [x] Add or update system specs for brand logo and favicon links.
- [x] Update UI screenshot automation to capture branding screenshots.
- [x] Update quality logs with evidence and follow ups.
- [x] Run required setup, tests, and screenshot commands.
- [x] Summarize results and commit changes.

## Surprises and Discoveries

Chrome was not available for Cuprite, so system specs that require a browser and bin/ui-screenshots reported pending or failures due to the missing binary.

## Decision Log

- Decision: Keep existing branding filenames because they are already clear.
  Rationale: The files are already named by color and purpose so renaming adds churn.
  Date/Author: 2026-02-08 Codex

## Outcomes and Retrospective

Brand logo rendering is centralized in a shared partial and wired into navigation and auth pages. Layouts now include light and dark favicon variants plus an apple touch icon link, with follow ups logged for icon sizing and browser media query limitations. System coverage was added for branding and screenshot automation was updated, but browser driven specs and screenshots still require Chrome in the environment.

## Context and Orientation

Branding assets live in app/assets/images/branding. Theme selection is stored on the user and applied as html classes via ApplicationHelper and a Stimulus controller. Layouts live in app/views/layouts and shared navigation in app/views/shared. Devise auth views live under app/views/devise.

## Plan of Work

First, confirm branding asset filenames and dimensions. Next, add a shared partial for the brand logo that renders both black and white assets and uses the root theme class to show the right one. Use the partial in the sidebar, topbar, and Devise auth pages. Then update the application and app shell layouts to include favicon link tags for light and dark variants, plus an apple touch icon link. Add system specs that verify a logo in navigation and auth pages and that favicon links exist in the head. Update the UI screenshot spec to save branding screenshots under tmp/screenshots/ui/branding. Record entries in the quality logs, especially noting if the apple touch icon size is not 180 by 180. Finally, run setup, tests, and screenshot automation, collect evidence, and commit.

## Concrete Steps

Run these commands from the repo root.

  - ls app/assets/images/branding
  - python script to read PNG sizes
  - rg for theme usage and existing logo markup
  - bundle install
  - RAILS_ENV=test bin/rails db:prepare
  - RAILS_ENV=test bin/rails tailwindcss:build
  - bundle exec rubocop
  - bundle exec brakeman
  - bundle exec bundler-audit check --update
  - bundle exec rspec
  - bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/cost_hub_import_spec.rb spec/system/navigation_spec.rb spec/system/navigation_routes_spec.rb spec/system/account_management_spec.rb
  - bin/ui-screenshots

## Validation and Acceptance

Visit the sidebar and auth pages and confirm the logo appears. Switch to the light theme and confirm the black logo appears. Check the head for favicon links including apple touch icon. Run the required tests and screenshot script and confirm screenshots are saved under tmp/screenshots/ui/branding.

## Idempotence and Recovery

If a step fails, re run the failed command. Layout changes are additive and can be reverted by restoring previous link tags. The shared partial can be removed safely if needed.

## Artifacts and Notes

Record screenshot paths from tmp/screenshots/ui/branding and add them to quality logs.

## Interfaces and Dependencies

Use Rails helpers image_tag, favicon_link_tag, and asset_path for asset pipeline managed images and icons.
