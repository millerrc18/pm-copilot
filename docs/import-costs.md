---
title: Importing costs
summary: Upload cost data with required fields, supported formats, and validation tips.
last_updated: 2026-01-31
category: Imports
---

# Importing costs

Cost imports let you track labor and material spend that isn’t tied to a single contract.

## Supported file formats

- CSV (.csv)
- Excel (.xlsx)

## Required fields

Include the following columns (case-insensitive):

- `period_type` (`week` or `month`)
- `period_start_date`
- `material_cost`
- `other_costs`

## Recommended fields

- `hours_bam`, `hours_eng`, `hours_mfg_salary`, `hours_mfg_hourly`, `hours_touch`
- `rate_bam`, `rate_eng`, `rate_mfg_salary`, `rate_mfg_hourly`, `rate_touch`
- `notes`

## Upload steps

1. Open **Cost Hub** from the sidebar.
2. Select **Import costs**.
3. Choose your file, optionally select a program, and upload.
4. Review any validation errors and re-upload if needed.

## Troubleshooting

- **Date errors**: Use ISO format (`YYYY-MM-DD`) for `period_start_date`.
- **Period type**: Only `week` or `month` are accepted.
- **Negative costs**: Numeric values must be zero or greater.

## Related guides

- [Cost tracking overview](/docs/cost-tracking)
- [Import milestones](/docs/import-milestones)
- [Import delivery units](/docs/import-delivery-units)
