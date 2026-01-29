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

All files are covered by the MIT license, see [LICENSE.txt](LICENSE.txt).
