---
title: Cost tracking hub
summary: Track contract-independent costs and unit-level efficiency in one place.
last_updated: 2026-01-31
category: Analytics
---

# Cost tracking hub

The Cost Hub captures labor and material spending that isn’t tied to a specific contract. Each **Cost Entry** represents a week or month of costs, which can be filtered by date range and program.

## Cost Entry fields

Each Cost Entry contains:

- `period_type`: `week` or `month`.
- `period_start_date`: the start of the week or month.
- `hours_*`: labor hours for BAM, Engineering, Manufacturing (salary/hourly), and touch hours.
- `rate_*`: hourly rates for each labor bucket.
- `material_cost`: direct material spend.
- `other_costs`: miscellaneous costs.
- `notes`: optional context about the entry.
- `program`: optional program association.

## Importing cost data

1. From the sidebar, open **Cost Hub**.
2. Select **Import costs**.
3. Optionally choose a program, then upload the `costs.xlsx` template.
4. Review the import summary and return to the Cost Hub.

The import template uses the headers listed on the import page. The previous `contract_code` column is no longer required.

## Using the Cost Hub

- **Filter by date range** to focus on a specific week or month window.
- **Filter by program** to isolate costs tied to a single program.
- **Total cost** aggregates all matching Cost Entries.
- **Units delivered** count Delivery Unit records shipped in the same period.
- **Average cost per unit** divides total cost by delivered units (shows zero when no units are delivered).

## Related guides

- [Import costs](/docs/import-costs)
- [Dashboard metrics](/docs/dashboard-metrics)
