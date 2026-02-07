# Fix ops imports queue runner and visibility

This ExecPlan is a living document. The sections Progress, Surprises and Discoveries, Decision Log, and Outcomes and Retrospective must be kept up to date as work proceeds.

This plan follows .agent/PLANS.md from the repository root and must be maintained in accordance with it.

## Purpose / Big Picture

Operations imports can remain queued if no Solid Queue worker is running. This work ensures we document the required worker process for production, capture job identifiers, and show import status updates with a clear refresh path so a user can confirm progress without hard reloads.

## Progress

- [x] Confirm current Active Job adapter and Solid Queue setup, and document the production worker requirement.
- [x] Persist and log Active Job job identifiers for ops imports, and add richer job logs for start, finish, and failure details.
- [x] Add import history refresh behavior and last updated visibility in the UI.
- [x] Add regression coverage for enqueued jobs and stored job identifiers.
- [x] Update quality logs, run required tests and screenshots, and prepare the PR deliverables.

## Surprises and Discoveries

Request spec coverage for job_id still reports a nil value in this environment even after enqueue updates, which needs follow up. Several system specs also failed due to missing tailwind assets or Chrome.

## Decision Log

- Decision: Use Solid Queue worker documentation and bin/jobs as the worker start command.
  Rationale: Production is configured for solid_queue and bin/jobs already wraps SolidQueue::Cli.
  Date/Author: 2026-02-16 / Codex

## Outcomes and Retrospective

Ops import enqueue logging and UI refresh details were added alongside Render worker documentation. The new request spec still fails to read job_id as persisted in this environment, and multiple system specs failed due to missing assets or browsers.

## Context and Orientation

Production sets config.active_job.queue_adapter to solid_queue in config/environments/production.rb. Ops imports are queued in OpsImportsController and processed by OpsImportJob, which writes status and row counts to OpsImport records. The ops imports history UI is rendered in app/views/ops_imports/index.html.erb.

## Plan of Work

First, verify Solid Queue configuration files and locate the worker command. Next, add a job_id column to ops_imports, persist it when enqueuing, and add structured logs for enqueue, start, finish, and failure. Then update the imports history UI to expose last updated timestamps and add a refresh mechanism using a Turbo frame and a lightweight Stimulus controller to trigger reloads. Add request spec coverage to assert the job is enqueued and job_id is stored. Finally, update Render deployment docs, maintain quality logs, run all required tests and screenshots, and summarize outcomes.

## Concrete Steps

Run rg to confirm queue adapter settings and inspect config/queue.yml and bin/jobs. Add a migration to ops_imports for job_id and update schema.rb. Update OpsImportsController to store job_id and log enqueue details. Update OpsImportJob to log start and finish details with durations. Create a new Stimulus controller under app/javascript/controllers for frame refresh, and update app/views/ops_imports/index.html.erb to render the history panel in a turbo frame with refresh controls. Update spec/requests/ops_imports_spec.rb to assert job_id storage. Update README.md with Render worker steps. Update docs/quality/issue_log.md and docs/quality/improvement_log.md. Run bundle exec rubocop, bundle exec brakeman, bundle exec bundler-audit check --update, bundle exec rspec, bundle exec rspec with the listed files, and bin/ui-screenshots.

## Validation and Acceptance

Run the required test suite commands and ensure they pass, or document failures due to environment limits. Verify the ops imports page shows a refresh button and last updated timestamp. Confirm logs include enqueue, start, and finish entries with job_id. Ensure the request spec asserts the job_id is stored and the job is enqueued.

## Idempotence and Recovery

If migrations or schema edits are wrong, regenerate the migration or revert the schema changes and rerun migrations. If the Turbo frame refresh misbehaves, revert to the standard page rendering and ensure the refresh button still reloads the frame.

## Artifacts and Notes

Capture UI screenshots via bin/ui-screenshots and the browser tool. Note any missing browser dependencies.

## Interfaces and Dependencies

Solid Queue is configured via config/queue.yml and started with bin/jobs. Ops imports are handled by OpsImportJob and OpsImportService. Turbo and Stimulus are used for UI refresh behavior.
