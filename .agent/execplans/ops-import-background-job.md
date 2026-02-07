# Fix operations import memory usage with streaming and jobs

This ExecPlan is a living document. The sections Progress, Surprises & Discoveries, Decision Log, and Outcomes & Retrospective must be kept up to date as work proceeds.

This plan is governed by .agent/PLANS.md from the repository root and must be maintained in accordance with it.

## Purpose / Big Picture

Operations imports currently load entire XLSX files in memory and write rows one at a time in a web request, which can trigger memory exhaustion on a small instance. After this change, uploads create a queued OpsImport record, enqueue a background job, and stream the XLSX rows with batched inserts so memory use stays low. A user can upload a report, see an Import started notice, and watch the import status change from queued to running to succeeded or failed in the Operations Imports screen.

## Progress

- [x] Capture current import entrypoints and update the ExecPlan with file locations.
- [x] Implement background job flow, attachments, and status tracking for ops imports.
- [x] Stream XLSX parsing with batched insert_all writes and structured logging.
- [x] Update UI error handling for guardrails and status details.
- [x] Add and update tests, then run required validation commands.
- [x] Update quality logs and summarize outcomes.

## Surprises & Discoveries

- System specs failed because tailwind.css was not available in the test asset pipeline, and Cuprite could not find Chromium.

## Decision Log

- Decision: Default OpsImport status will change from completed to queued for new records and existing completed records will be migrated to succeeded.
  Rationale: The new flow is asynchronous and needs explicit queued, running, and succeeded states.
  Date/Author: 2026-02-07 Codex

## Outcomes & Retrospective

Operations imports now enqueue background jobs, stream XLSX rows, and batch insert records to reduce memory pressure. Guardrails prevent oversized files and surface upload errors. Tests and validation commands were run, but system specs failed due to missing test assets and Chromium.

## Context and Orientation

Operations imports are handled by OpsImportsController create and OpsImportService. OpsImportService uses Roo to read the spreadsheet, iterates rows, and creates ActiveRecord models per row. OpsImport is the parent record and currently defaults to status completed. The Operations Imports page renders the import history and shows errors for failed imports.

## Plan of Work

First, change OpsImport to track an attached source file, new statuses, and error_message. Next, update OpsImportsController to validate file size, create a queued OpsImport with the attached file, and enqueue a background job. Then, update OpsImportService to accept an OpsImport and a file path, stream rows with each_row_streaming, and use insert_all in batches while tracking counts and logging. Add OpsImportJob to run the service, update statuses, and handle errors. Finally, update the Operations Imports UI to surface status and error details, adjust tests, and log evidence in the quality logs.

## Concrete Steps

Run the following commands from the repository root as needed.

- rg -n "OpsImport" app/controllers app/services app/models
- bin/rails g migration AddErrorMessageToOpsImports error_message:string
- bundle exec rspec spec/services/ops_import_service_spec.rb
- bundle exec rspec spec/requests/ops_imports_spec.rb
- bundle exec rubocop
- bundle exec brakeman
- bundle exec bundler-audit check --update
- bundle exec rspec
- bundle exec rspec spec/models/cost_entry_spec.rb spec/system/cost_hub_spec.rb spec/system/cost_hub_import_spec.rb spec/system/navigation_spec.rb spec/system/navigation_routes_spec.rb spec/system/account_management_spec.rb
- bin/ui-screenshots

## Validation and Acceptance

A user uploads a valid XLSX file from Operations Imports, sees an Import started notice, and the import appears with queued or running status. After the job runs, the import shows succeeded with rows imported, and OpsMaterial rows are present for the report. Attempting to upload an oversized file returns status 422 with a friendly error in the form.

## Idempotence and Recovery

If an import fails, the OpsImport record is marked failed and can be deleted by an admin. Re running the job is safe only for new OpsImport records because duplicates are prevented by checksum and report type. If any step fails, revert the migration and delete the OpsImportJob file, then reset OpsImportService to the prior synchronous approach.

## Artifacts and Notes

Track logs with ops_import_id, report_type, rows processed, batch counts, and duration. Capture test outputs in docs/quality logs.

## Interfaces and Dependencies

Use Roo::Excelx with each_row_streaming for streaming access. Use ActiveStorage for file attachment, ActiveJob for background execution, and insert_all for batched writes.
