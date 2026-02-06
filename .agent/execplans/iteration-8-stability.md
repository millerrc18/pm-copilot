# Iteration 8 stability fixes across operations, contracts, delivery, risks, and flash messaging

This ExecPlan is a living document. The sections Progress, Surprises & Discoveries, Decision Log, and Outcomes & Retrospective must be kept up to date as work proceeds.

This document must be maintained in accordance with .agent/PLANS.md from the repository root.

## Purpose / Big Picture

Users should be able to open Operations dashboards without migration banners, create contract periods and delivery records without hidden inputs, manage risks in the register, and see consistent flash messaging in Turbo forms. Operations pages must render empty states when no data exists, cost entry totals should update live, and Render deploys should run migrations. These outcomes are visible by loading the dashboards, creating records, and seeing success and error messaging with valid and invalid submissions.

## Progress

- [x] Review current Operations guards, dashboards, and Render deploy scripts to determine the migration banner behavior and empty data handling.
- [x] Repair contract period creation, date input UX, and error handling plus add request specs for success and failure.
- [x] Fix delivery unit ship date parsing and milestone date inputs, add validations or parsing helpers, and add request specs.
- [x] Improve cost hub inputs and add live total cost Stimulus behavior plus system spec coverage.
- [x] Verify risk register routes and navigation, align UI fields, add missing fields or validations, and add model and request specs.
- [x] Standardize flash messaging for Turbo responses across key controllers and layout.
- [x] Update docs quality logs, capture UI screenshots, run required tests, and prepare commit and PR details.

## Surprises & Discoveries

The mitigation migration needed a timestamp earlier than the repo limit and initially ran before the risks table, which required replacing it with a later migration in the accepted range. Running db:migrate in development triggered the ERD task, which failed without GraphViz.

## Decision Log

- Decision: Use date field inputs for period and milestone forms to reduce partial date submission issues.
  Rationale: Single input reduces UX errors and matches existing date field usage in the app.
  Date/Author: 2025-02-14 / Codex
- Decision: Add a new mitigation migration with an allowed timestamp rather than keeping the earlier one that ran before the risks table.
  Rationale: The earlier timestamp ran before the risks table and was outside the allowed range, so a later migration ensures the column exists reliably.
  Date/Author: 2026-02-06 / Codex

## Outcomes & Retrospective

Delivered Operations empty states and schema guard behavior, fixed contract period, milestone, and delivery unit date inputs, added risk mitigation notes, and added live cost totals. System specs still fail locally without Chrome, and db:migrate in development needs GraphViz or a skip option.

## Context and Orientation

Operations dashboards live under app/controllers/operations and app/views/operations. The schema guard that shows the Operations setup banner is in app/controllers/concerns/operations_schema_guard.rb. Contract periods, delivery units, and milestones have their own controllers and form partials under app/controllers and app/views. Risks already have a controller, model, and views but must be verified for accessibility and aligned to requested fields. Flash messaging is handled in the application layout and turbo stream responses. Render deploy scripts live in bin/render-build.sh and render.yaml.

## Plan of Work

First, inspect Operations controller guards, dashboard views, and Render build scripts to confirm when the schema banner renders and to plan empty state changes. Next, update contract period forms and controller error handling, and add request specs. Then fix delivery unit ship date parsing and milestone date fields and add relevant request specs. After that, improve cost entry inputs, add a Stimulus controller for live totals, and add a system spec. Then verify risk register routes and navigation, adjust model, controller, and views to support required fields and filters, and add model and request specs. Finally, add consistent flash container support and turbo stream flash updates in relevant controllers, update quality logs, run required tests and UI screenshots, capture manual screenshots, and prepare commit and PR notes.

## Concrete Steps

Run these commands from the repository root:

  - rg "Operations is being set up" -n
  - rg "operations" app/controllers -n
  - cat app/controllers/concerns/operations_schema_guard.rb
  - cat bin/render-build.sh
  - cat render.yaml
  - rg "contract_period" app -n
  - rg "delivery_unit" app -n
  - rg "delivery_milestone" app -n
  - rg "cost_entries" app/views -n
  - rg "risk" app/controllers app/views app/models -n

Edit the identified files for each task and add new specs under spec/requests and spec/models. Add new Stimulus controllers under app/javascript/controllers and update any views to reference them. Update docs/quality logs with dated entries and evidence references.

## Validation and Acceptance

Run the required test commands listed in AGENTS.md. Confirm in a browser that Operations dashboards show empty states with links to Operations imports, that contract period and milestone date inputs use a single date field, that delivery units accept typed ship dates, that cost totals update live, and that risk register loads with filters. Confirm flash messages appear for create and failure states in period, delivery unit, milestone, cost entry, and risk flows.

## Idempotence and Recovery

All migrations should be safe to re run and should check for existing columns or use Rails migrations that are idempotent by default. If a migration fails, rollback with bin/rails db:rollback and rerun. If a test fails due to missing browser, set FERRUM_BROWSER_PATH as documented and re run.

## Artifacts and Notes

Capture UI screenshots via bin/ui-screenshots to tmp/screenshots/ui and additional manual screenshots for Operations empty states, period success and failure, risks index, and cost total updates. Do not commit screenshots. Record their paths in the PR and quality logs.

## Interfaces and Dependencies

Use Rails form helpers, Turbo, and Stimulus controllers consistent with existing UI components. Use existing risk, cost, delivery, and operations models and controllers to avoid duplicating behavior. Use Render deploy scripts for migrations.
