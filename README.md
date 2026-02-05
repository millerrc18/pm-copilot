# PM Copilot (Capstone)

PM Copilot is a Rails app that helps program teams track program financials and delivery performance with a single source of truth. It supports Programs, Contracts, cost tracking by period, delivered unit tracking, contractual delivery milestones, and simple dashboards that roll metrics up to the Program level.

## Features

- Authentication (Devise)
- Programs
  - Program dashboard (aggregated metrics across all contracts)
- Contracts (under a Program)
  - Cost periods (weekly or monthly)
  - Delivered units (unit-level shipments)
  - Delivery milestones (contractual promises: qty due by date)
- Excel imports (separate importers)
  - Delivery Units importer
  - Costs importer
  - Milestones importer (supports amendment-related fields)

## Data sources (source of truth)

- Shipped units and delivery rollups are based on `DeliveryUnit` records (unit-level shipments). Do not use or recreate an aggregated delivery-events table.
- Contractual due quantities and on-time delivery metrics come from `DeliveryMilestone` records.
- Revenue and cost rollups come from `ContractPeriod` records.

## UI screenshots

Generate responsive UI screenshots for Apple device viewports:

```bash
bin/ui-screenshots
```

Screenshots are written to `tmp/screenshots/ui/<page>/<device>.png`.

## Deployment

Production deploys must run database migrations before starting the web process. The Render start script runs `bin/rails db:migrate` followed by `bin/rails ops:schema:check` to fail fast if Operations tables or saved filter columns are missing.

## Manual QA checklist (first release)

Functional
- Sign up, sign in, sign out.
- Create program, edit program.
- Create contract under a program.
- Import delivery units, costs, milestones with a small sample file.
- Verify dashboard totals update correctly after import.

UI behavior
- Sidebar collapse toggle works and persists after refresh.
- Mobile off-canvas sidebar opens/closes.
- Keyboard navigation: tab order makes sense, focus ring visible.
- Buttons have 44x44 targets on iPhone viewports.
- Right panel collapses appropriately on iPad and iPhone.

Safari specific
- iOS Safari: no content hidden behind notch or home indicator (safe area respected).
- Scroll works smoothly inside main content.
- Backdrop blur renders correctly or degrades gracefully.
- No 100vh jump when browser chrome shows/hides (uses 100dvh).

All files are covered by the MIT license, see [LICENSE.txt](LICENSE.txt).
