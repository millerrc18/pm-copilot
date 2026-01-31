Iteration 5: Risk and Opportunities, Planning Hub, Unified Imports, Saved Views, Enhanced Metrics, Export & Notifications, Documentation & Search, UI Improvements

This document is an ExecPlan. It is a living, self-contained design and execution guide for Iteration 5 of PM Copilot, a Rails 8 application that helps program managers track contracts, costs and deliveries. It follows the conventions defined in .agent/PLANS.md (if present) and is written for a new contributor with no prior knowledge of the repository. The reader should be able to implement all listed features end-to-end by following the instructions herein and by keeping the Progress, Surprises & Discoveries, Decision Log and Outcomes & Retrospective sections up to date as work proceeds.

Purpose / Big Picture

Iteration 5 expands PM Copilot from a cost-tracking dashboard into a comprehensive program management tool. Users will be able to:

Record risks and opportunities at the program and contract level, score them by probability and impact, and track mitigation actions.

View and edit schedules in a new Planning Hub that displays contract periods, milestones and delivery units on a timeline (Gantt) and allows rescheduling.

Import costs, milestones and units via a unified Imports Hub, with downloadable Excel templates and row-level validation.

Save their preferred filters on the Contracts and Cost Hub pages (e.g., current year, date range, program) so those views persist across visits.

See return on cost (ROC) and return on sales (ROS) metrics on Program pages, along with additional charts showing cost and delivery trends.

Export cost data and program summaries to Excel and PDF, and receive email notifications for upcoming milestones and critical risks.

Navigate a clearer Knowledge Center with improved search and interleaved tutorials; find help quickly.

Enjoy a refined UI with cross-platform search hints, improved loading feedback and polished forms.

A human can verify success by logging in, creating risks and viewing them in the register, using the Planning Hub to adjust dates, importing data from all three templates, saving filter preferences, viewing new metrics on program pages, exporting data, receiving emails, searching docs and experiencing the improved UI.

Progress

Use checkboxes to track granular steps. Update this list as tasks start and finish.

 (YYYY-MM-DD HH:MM) Milestone 0: Orientation. All relevant files and routes identified; audit notes recorded in docs/quality/issue_log.md.

 (YYYY-MM-DD HH:MM) Milestone 1: Risk & Opportunity Tracker implemented with models, CRUD pages and summary widgets; tests passing; screenshots taken.

 (YYYY-MM-DD HH:MM) Milestone 2: Planning Hub implemented with timeline view and editing; tests passing; screenshots taken.

 (YYYY-MM-DD HH:MM) Milestone 3: Unified Imports Hub implemented with tabs for costs, milestones and delivery units; templates committed; tests passing; screenshots taken.

 (YYYY-MM-DD HH:MM) Milestone 4: Saved view functionality added to Contracts and Cost Hub pages; tests passing; screenshots taken.

 (YYYY-MM-DD HH:MM) Milestone 5: ROC/ROS metrics and additional analytics implemented on Program pages; tests passing; screenshots taken.

 (YYYY-MM-DD HH:MM) Milestone 6: Data export (Excel/PDF) and email notifications implemented; tests passing.

 (YYYY-MM-DD HH:MM) Milestone 7: Documentation & search improvements delivered; tests passing.

 (YYYY-MM-DD HH:MM) Milestone 8: UI & UX improvements delivered (cross-platform search hints, loading indicator, accessibility fixes); tests passing.

 (YYYY-MM-DD HH:MM) Final validation: All AGENTS.md commands and UI screenshot tasks executed; logs updated; PR ready.

Surprises & Discoveries

Record unexpected behaviours, bugs or insights found during work. Provide short evidence snippets (test output, screenshots or logs).

Observation: [example] The date picker component renders differently in Safari than Chrome.
Evidence: …

Decision Log

Record every decision (choice of library, data model design, UI pattern, etc.) with rationale.

Decision: Use Chartkick + Chart.js for Gantt and analytics charts rather than a heavier library like FullCalendar.
Rationale: Chartkick is already in use for current cost charts, reducing dependencies and complexity.
Date/Author: YYYY-MM-DD / dev-name

Outcomes & Retrospective

Summarize what was achieved and lessons learned at each milestone or at completion. Capture gaps and next steps.

Context and Orientation
Repository structure relevant to this iteration

app/models/: Contains Rails models such as Program, Contract, CostEntry, DeliveryUnit, DeliveryMilestone. Each contract belongs_to a program; cost entries belong_to a program and are not tied to contracts.

app/controllers/: Contains controllers like ProgramsController, ContractsController, CostHubController. Import functionality lives in CostImportsController. There are no controllers yet for risks or planning.

app/views/: Contains ERB templates. Navigation is defined in app/views/shared/_sidebar.html.erb. The account page is in app/views/users/edit.html.erb (and corresponding partials).

config/routes.rb: Defines resources for programs, contracts, cost imports, cost entries, etc. It does not yet route to risk registers or planning.

docs/quality/issue_log.md and improvement_log.md: Running logs for issues and enhancements.

spec/: Contains RSpec model, controller and system tests, including spec/system/cost_hub_spec.rb and spec/system/navigation_spec.rb.

Existing functionality (reference from site)

Cost Hub: Users can filter by date and program, view total cost, units delivered and average cost per unit; charts show cost over time and cost components; manual cost entry works via a form.

Contracts page: Lists all contracts across programs with planned quantity and revenue; there is no year-based filter yet.

Registers: Delivery units and milestones have global registers with edit/delete actions.

Knowledge Center: Provides guides (Cost tracking, Contract management) with search box; navigation groups docs separately.

Account page: Overhauled earlier; shows user details, theme options and lifetime stats.

User-facing goals in this iteration

Risks and opportunities must be tracked in a dedicated register; managers need to record probability, impact, severity and status.

Schedules should be visualized and adjustable; users must see when periods, milestones and deliveries occur.

Import workflows should be consolidated; row-level errors must be clearly visible.

Users expect to save and persist filters and views across sessions (for Contracts and Cost Hub).

New metrics (ROC/ROS) and charts need to surface program performance more comprehensively.

They want to extract data for offline analysis (Excel/PDF) and get timely alerts for deadlines and risk conditions.

The Knowledge Center should offer better navigation and search; new guides may be added.

UI must be polished: consistent hints across OSes, accessible colour contrast, premium loading indicators.

Plan of Work

The work is divided into eight milestones. Each milestone describes the goal, the edits/additions required, acceptance criteria, tests and concrete implementation steps. Follow them sequentially; each milestone should be committed separately and leave the codebase in a stable state.

Milestone 0 - Orientation and Audit

Goal: Understand current code related to imports, costs, contracts, programs, documentation and UI; record notes.

Work:

Read AGENTS.md to understand the required commands and screenshot expectations.

Inspect config/routes.rb for existing routes; note missing endpoints (e.g., risks, planning_hub).

Read models in app/models to understand data relationships. Verify that CostEntry belongs_to Program and is not tied to Contract. Note that Return on Cost/Sales metrics are not implemented.

Note all existing controllers and views; identify where new pages will go.

Record orientation notes in docs/quality/issue_log.md with the heading “Iteration 5 Audit” and date.

Acceptance: issue_log updated with orientation notes and current page mapping.

Milestone 1 - Risk & Opportunity Tracker

Goal: Create a full CRUD system for risks and opportunities tied to programs or contracts, with scoring and status tracking.

Implementation steps:

Model: Generate a Risk model with attributes:

program_id (nullable) and contract_id (nullable) - exactly one of these must be present.

title: string; description: text.

probability: integer (0-100) or float (0.0-1.0).

impact: integer or float (same scale as probability).

type: enum (risk, opportunity).

status: enum (open, closed, mitigated, postponed).

owner: string or reference to User (optional).

due_date: date (optional).

Timestamps.

Add validations: presence of title, numeric ranges for probability/impact, and a custom validation ensuring either program_id or contract_id is present but not both.

Controller & Routes: Add resources :risks nested under programs and contracts. Provide index, new, create, edit, update and destroy actions. Also add a top-level /risks route listing all risks across programs (optional but useful for a global register).

Views: Create views:

app/views/risks/index.html.erb - table listing risks with columns for title, probability, impact, severity (probability × impact), status, due date, and owner. Include filter controls (by program, contract, type, status) and a chart summarising risk counts by severity.

new.html.erb and edit.html.erb - forms to create/edit a risk. Use a slider or dropdown for probability and impact; radio buttons for type; select for status; date picker for due date. Provide a “Save risk” and “Cancel” button.

show.html.erb (optional) - detail view with risk history, attachments and comments (can be deferred).

Risk summary widgets: On the dashboard (Programs index) or contract pages, add small widgets summarising the number of open risks, critical risks (severity > threshold), and opportunities. Provide links to the Risk register filtered accordingly.

Tests:

Model tests verifying validation rules and severity calculation.

Controller tests for CRUD actions (create, update, delete) and access control (only logged-in users can modify).

System tests to add a risk, edit it and verify its presence in the register and summary widgets.

Screenshot tests capturing the Risk register in desktop, iPad and iPhone views.

Documentation: Add a new guide to the Knowledge Center explaining how to use the Risk & Opportunity tracker: definitions, scoring methodology, and how to update statuses.

Acceptance criteria: Users can create, view, edit and delete risks for a program or contract; severity scores appear correctly; summary widgets update; tests pass and screenshots exist.

Milestone 2 - Planning Hub

Goal: Provide a Gantt or timeline view showing contract periods, milestones and delivered units, with editing capability.

Implementation steps:

Route and Controller: Add a PlanningHubController with an index action. Define a route /planning-hub in routes.rb and a corresponding nav item under Workspace.

Data aggregation service: Create a service object (e.g., PlanningTimelineService) that assembles data for a selected program (or all programs) into JSON for timeline display. For each contract period, milestone and delivered unit, compute start and end dates and labels. Use the existing contract_period, delivery_milestone and delivery_unit models.

Timeline UI: Use Chartkick + Chart.js or a lightweight Gantt library to render the timeline. Chartkick’s timeline chart can plot tasks with start and end dates. For each item, include a popover with details (e.g., contract code, period type, quantity, milestone ref, unit serial).

Editing: Allow dragging bars to change start/end dates (if feasible) and double-click to edit details. On drag end or edit, send an AJAX request to update the underlying record (update period_start_date, due_date or shipped_at). Provide a confirmation dialog.

Filters: Offer filters to narrow by program, contract, or date range. Provide a legend for different item types (contract periods, milestones, units).

Tests:

Service tests verifying the timeline JSON structure and correct inclusion of items.

System tests verifying the timeline renders with the correct number of items and that editing a bar updates the record.

Screenshot tests for timeline view.

Documentation: Add a guide “Planning Hub” explaining how to use the timeline, adjust dates and interpret colours.

Acceptance: Users can view a timeline of periods, milestones and units; edit dates by dragging; filter by program or contract; timeline persists updates.

Milestone 3 - Unified Imports Hub

Goal: Replace the single-purpose Cost Imports page with a unified imports hub where users can import costs, milestones and delivery units, each with its own template and validation.

Implementation steps:

Navigation: Rename Cost Imports in the sidebar to Imports (or Data Imports). Update the nav partial accordingly.

Controller: Create ImportsController with actions index, costs, milestones, units. The index view will contain a tabbed interface with three forms.

Templates: Commit three .xlsx files under public/templates/:

costs.xlsx - headers: period_type, period_start_date, hours_bam, hours_eng, hours_mfg_salary, hours_mfg_hourly, hours_touch, rate_bam, rate_eng, rate_mfg_salary, rate_mfg_hourly, rate_touch, material_cost, other_costs, notes.

milestones.xlsx - headers: contract_code, milestone_ref, promise_date, quantity_due, notes, amendment_code, amendment_effective_date, amendment_notes.

delivery_units.xlsx - headers: contract_code, unit_serial, shipped_at, notes.

Forms: Each tab’s form should contain:

Program select (when applicable; costs require program, milestones/units validate contract codes to belong to program).

File input restricted to .xlsx.

Link to download the relevant template.

List of required headers.

Import button.

Import logic: Refactor existing cost import service to support program-scoped costs and remove contract_code parameter. Create similar services for milestones (MilestoneImportService) and units (DeliveryUnitImportService) that handle multiple contracts, validate codes, and collect row errors. Decide on all-or-nothing behaviour: if any row has errors, reject the entire file and show error summary. Log each import in the database (e.g., ImportBatch model) for auditing.

Validation feedback: Display a table summarizing any errors, with row number and message, before creating records. If no errors, create records and show success message with counts.

Tests:

System tests uploading valid and invalid files for each import type; verify records created or errors displayed.

Tests for template download endpoints.

Screenshot tests for each tab on desktop/iPad/iPhone.

Documentation: Extend the Knowledge Center’s cost tracking guide and add new guides for milestone and unit imports.

Acceptance: A unified Imports hub exists, with functioning template downloads, per-row validation and record creation for costs, milestones and units.

Milestone 4 - Saved Views for Contracts and Cost Hub

Goal: Allow users to persist their preferred filters on the Contracts index and Cost Hub pages.

Implementation steps:

Data model: Create a UserPreference model (if not existing) with polymorphic pref_key and pref_data fields. Example keys: contracts_view, cost_hub_view.

Contracts index:

Implement year-based filters (current year, next year, pick a year, all). Use contract start/end dates or cost/delivery periods to determine activity.

After user selects a filter and clicks “Save as default view,” store the selection in UserPreference keyed by user and contracts_view.

On page load, if a saved preference exists, apply it.

Cost Hub:

Persist date range and program selections similarly (cost_hub_view).

Provide “Save as default view” and “Reset to defaults” controls.

Tests:

System tests verifying saved preferences persist across sessions for both pages.

Tests verifying correct filtering: for contracts, only current-year contracts appear by default; for cost hub, date/program filters produce correct totals.

Documentation: Update guides for contracts and cost hub to explain saved views.

Acceptance: Users can set a default filter for each page, and it persists; system tests pass.

Milestone 5 - Enhanced Metrics and Analytics

Goal: Surface more informative metrics and charts to help users evaluate program performance.

Implementation steps:

Return on Sales (ROS) and Return on Cost (ROC):

Add methods to Program model (or a presenter) to compute:

Profit = revenue_to_date - cost_to_date.

ROS = Profit / revenue_to_date (return “N/A” if revenue is zero).

ROC = Profit / cost_to_date (return “N/A” if cost is zero).

Add tooltips explaining these metrics; update the program show view to display them next to cost and revenue.

Enhanced charts on Program page:

Add a line chart for cost per unit over time (cost_to_date divided by cumulative units delivered per period). Use Chartkick’s line chart.

Add a bar/line chart comparing revenue and cost per period.

Provide toggles to switch between weekly and monthly views.

Enhanced charts on Cost Hub:

Add a bar chart showing unit cost distribution across period types (e.g., weekly vs monthly). Use the aggregated cost and units delivered for each period.

Add a stacked bar chart showing cost composition (labor vs material vs other) over time.

Tests:

Unit tests for ROC/ROS calculations (including zero and negative values).

System tests verifying charts appear and that tooltips exist.

Screenshot tests capturing the new charts.

Documentation: Expand the cost tracking guide to explain ROS/ROC and new charts.

Acceptance: Program pages display ROC/ROS with correct values; new charts render; tests and screenshots pass.

Milestone 6 - Data Export and Notifications

Goal: Allow exporting data as Excel/PDF and send email alerts for deadlines and critical risks.

Implementation steps:

Excel/PDF export:

Use the axlsx gem to generate Excel files and prawn or wicked_pdf for PDF exports.

Add export buttons on the Cost Hub (export the filtered view as XLSX), Contracts index (export list), and Risk register (export list). For PDF, generate a program summary or risk report.

Implement controllers/actions to generate and send the file; ensure correct MIME types.

Respect user filters when exporting.

Email notifications:

Configure Action Mailer if not already configured (use development SMTP for dev/test; doc states environment variables hold credentials for production).

Create mailer classes for milestones due soon, contract expiry reminders, and critical risk alerts. Use a background job system (SolidQueue or Sidekiq if configured).

Schedule periodic jobs (daily or weekly) to check upcoming milestones (due_date within X days) and send emails to program owners.

Tests:

Unit tests for exporter modules (correct headers, row counts).

System tests for export endpoints (files can be downloaded and opened with expected structure).

Mailer tests verifying emails are queued with correct recipients and content.

Documentation: Add a “Exports & Alerts” guide to the Knowledge Center explaining how to generate reports and configure notifications.

Acceptance: Users can download Excel and PDF reports; scheduled emails send notifications; tests pass.

Milestone 7 - Documentation & Search Improvements

Goal: Enhance the Knowledge Center with improved navigation and search; create interactive tutorials.

Implementation steps:

Navigation: Group docs by topic (Analytics, Contract management, Imports, Risks) with clear headings. Add breadcrumbs and side navigation within docs.

Search: Implement a simple search across markdown titles and summaries using a server-side search (e.g., pg_search gem) or a JS library; highlight matches.

Interactive tutorials: Add inline tips or modals on key pages (e.g., Cost Hub, Risk register, Planning Hub) that link back to the Knowledge Center. Use Stimulus controllers and data-action triggers.

Docs writing: Add new guides covering:

Risk & opportunity tracker.

Planning Hub timeline usage.

Imports Hub step-by-step.

Saved views.

Enhanced metrics.

Export & notifications.

Tests:

System tests verifying the doc pages render and search returns results.

Clickthrough tests for interactive tutorials.

Acceptance: Users can easily navigate docs, search topics, and find interactive help; tests pass.

Milestone 8 - UI & UX Improvements

Goal: Polish the interface with cross-platform hints, accessible components and improved loading feedback.

Implementation steps:

Cross-platform search hints: Update search bar components to show dynamic keytips (⌘K on Mac, Ctrl+K on Windows/Linux). Use JavaScript (navigator.platform) to detect OS and adjust hint text. Provide a generic label if detection fails.

Loading indicator: Style Turbo’s progress bar to match the new accent colours (dark/coral, dark/blue, light). Add a global spinner that appears whenever aria-busy is true on <html>. Use CSS animations and respect prefers-reduced-motion.

Accessibility improvements: Audit forms and controls for colour contrast and focus states. Ensure select elements in dark mode are readable (fixes the program dropdown issue). Add ARIA labels to icons and interactive elements.

QA: Write system tests to detect the presence of the progress bar/spinner when navigating or submitting forms. Add screenshot tests for the loading states if deterministic.

Documentation: Add a short “Using search and keyboard shortcuts” guide; update docs for new theme options if themes are extended further.

Acceptance: UI shows correct keytips on all platforms; loading indicators appear and disappear appropriately; forms meet contrast standards; tests and screenshots pass.

Concrete Steps

This section provides command-level guidance for each milestone. These commands assume a Unix-like environment with Ruby and Rails installed. Replace YYYY-MM-DD timestamps with current dates and times.

Open a terminal at the repo root and check out a new branch:

git checkout -b iteration-5


Run the test suite and linting to establish a baseline:

bundle install
RAILS_ENV=test bin/rails db:prepare
bundle exec rubocop
bundle exec brakeman
bundle exec bundler-audit check --update
bundle exec rspec
bin/ui-screenshots


Record any failures in issue_log; fix only those that block new work.

Proceed with milestones sequentially. After each milestone:

Write or update tests.

Run the full suite and screenshot tasks.

Commit changes with a descriptive message (git add . && git commit -m "Milestone X: …").

Update docs/quality/issue_log.md and docs/quality/improvement_log.md with what was done, evidence, and any new issues or improvements identified.

Push branch to GitHub and open a pull request when iteration is complete.

Validation and Acceptance

Each milestone must meet its acceptance criteria. At final validation:

All commands listed in AGENTS.md run without new failures.

All new or updated tests pass.

UI screenshot directories for each page exist in tmp/screenshots/ui/ with expected images (Cost Hub, Contracts, Imports hub, Risk register, Planning hub, Program pages, Account page across themes and states).

docs/quality/issue_log.md and docs/quality/improvement_log.md have updated entries with timestamps, descriptions, and evidence.

Pull request description summarises the milestones completed, tests run and remaining known issues.

Idempotence and Recovery

Database migrations must be reversible (define both up and down methods or use reversible blocks).

Imports must support all-or-nothing semantics; if an import fails, no partial records should remain. Provide instructions for rolling back an import (e.g., delete the ImportBatch and dependent records).

Saved views and user preferences should be safe to update repeatedly and removed cleanly if a preference is deleted.

Notifications should be idempotent: a job should check if a reminder has already been sent before sending again.

Artifacts and Notes

Include relevant diffs, command outputs or logs here when updating the ExecPlan. Use indented code blocks for transcripts. For example:

$ bundle exec rspec spec/models/risk_spec.rb
...
Finished in 0.1234 seconds (files took 0.4567 seconds to load)
10 examples, 0 failures

Interfaces and Dependencies

Charting: Chartkick + Chart.js is already a dependency; use it for all new charts (timeline, cost composition, etc.).

File imports: Use Roo for reading .xlsx files (already used in cost imports). Do not add heavy spreadsheet gems.

Exports: Use axlsx for Excel exports and prawn or wicked_pdf for PDF. If wicked_pdf is used, ensure wkhtmltopdf is available in dev/test.

Email: Use Action Mailer with existing mailer configuration; schedule jobs via SolidQueue or configured queue adapter.

Search: Use pg_search or a simple SQL LIKE query for documentation search.

Authentication: Continue using Devise for user sessions; do not bypass login in new features.
