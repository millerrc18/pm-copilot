# PM-Copilot Improvement Log

This is a living document that tracks product improvements and refinements across iterations. It is meant to be updated continuously as issues are discovered, features are refined, and UX polish opportunities emerge.

## How to use this log

- Add new items as soon as they are discovered.
- Keep each item small and testable.
- Link each improvement to one or more issues in `docs/quality/issue_log.md` (or create the issue if it does not exist yet).
- When an improvement is implemented, note the PR, date, and what evidence exists (tests, screenshots).

## Status definitions

- **Proposed**: identified but not yet scheduled.
- **Planned**: selected for an upcoming iteration, has acceptance criteria.
- **In progress**: being implemented.
- **Blocked**: waiting on dependency or decision.
- **Done**: implemented and verified.

## Current priorities (Iteration 3)

1. Program-scoped costs: costs must never be shared across programs.
2. Cost workflow: users can create, edit, delete, and duplicate cost entries, not only import.
3. Navigation clarity: Cost Hub under Workspace; Imports retains import templates.
4. Visualizations: lightweight charts for Cost Hub and Contract pages.
5. UI polish: dark-theme readability on form controls (including the Cost Import program select).

## Improvements backlog

### IMP-001 Program-scoped costs

- **Status**: Planned
- **Why**: Programs are the top-level boundary. Costs cannot be shared across programs.
- **Approach**:
  - Enforce `CostEntry belongs_to Program` with `program_id` required.
  - Ensure imports assign `program_id` to created cost entries.
  - Audit all aggregations and scoping to prevent cross-program mixing.
- **Acceptance criteria**:
  - Every cost entry belongs to exactly one program.
  - Cost Hub totals and charts never include costs from other programs.
  - Contract metrics, when showing cost, are explicitly program-scoped.
- **Evidence required**:
  - Model specs for validation.
  - System spec that creates two programs and verifies costs never mix.
  - Screenshots of Cost Hub with program filtering.

### IMP-002 Cost entry CRUD (manual entry, edit, delete, duplicate)

- **Status**: Planned
- **Why**: Import-only cost entry blocks adoption and prevents correcting mistakes.
- **Approach**:
  - Add Cost Entries create/edit/delete UI.
  - Add duplicate action to prefill a new entry from an existing entry.
  - Ensure totals update immediately.
- **Acceptance criteria**:
  - User can create a cost entry from UI.
  - User can edit imported costs.
  - User can delete costs with confirmation.
  - User can duplicate a cost entry.
- **Evidence required**:
  - System specs for create/edit/delete/duplicate.
  - Screenshots of new and edit forms.

### IMP-003 Navigation and information architecture

- **Status**: Planned
- **Why**: Cost Hub should be in Workspace; Imports should stay import-related.
- **Approach**:
  - Move Cost Hub link into Workspace group.
  - Keep Cost Import templates under Imports.
  - Rename Docs to Knowledge Center or Documentation and place outside Workspace.
- **Acceptance criteria**:
  - Sidebar grouping matches the intended structure across desktop, iPad, iPhone.
- **Evidence required**:
  - Navigation system spec.
  - Sidebar screenshots in all viewports.

### IMP-004 Cost Hub visualizations

- **Status**: Proposed
- **Why**: Tables are hard to scan. Visual summaries improve insight.
- **Approach**:
  - Add a small set of charts that respect program and date filters.
  - Limit to 2 to 3 charts maximum to avoid clutter.
- **Candidate charts**:
  - Total cost over time (line chart).
  - Cost composition over time (stacked bar).
  - Unit cost over time (line) when units exist in selected range.
- **Acceptance criteria**:
  - Charts render with seeded data.
  - Charts update when filters change.
- **Evidence required**:
  - System spec asserting chart containers render.
  - Screenshots for each viewport.

### IMP-005 Contract visualizations

- **Status**: Proposed
- **Why**: Contracts need quick signals: delivery trend, progress vs plan.
- **Candidate charts**:
  - Delivered units over time (bar or line).
  - Cumulative delivered vs planned quantity (burn-up).
- **Acceptance criteria**:
  - Charts render and respect the contract context.
- **Evidence required**:
  - System spec with seeded deliveries.
  - Screenshots.

### IMP-006 Dark-theme form control readability

- **Status**: Planned
- **Why**: Some controls (notably select dropdowns) are unreadable in dark mode.
- **Approach**:
  - Standardize Tailwind classes for inputs and selects.
  - Ensure focus ring and hover states are consistent.
- **Acceptance criteria**:
  - All primary controls meet readable contrast in dark theme.
- **Evidence required**:
  - Screenshots of forms.

### IMP-007 Search keytips cross-platform

- **Status**: Proposed
- **Why**: Current hint is Mac-specific.
- **Approach**:
  - Show Cmd+K on Mac and Ctrl+K on Windows/Linux, or show a neutral hint.
- **Acceptance criteria**:
  - Hint is not misleading for Windows users.
- **Evidence required**:
  - System spec if feasible.
  - Screenshot evidence.

## Completed improvements

None recorded yet in this log.
