---
title: Importing costs
summary: Upload cost data with required fields, supported formats, and validation tips.
last_updated: 2025-02-14
category: Imports
---

# Importing costs

Cost imports let you track actuals and projections at the contract period level.

## Supported file formats

- CSV (.csv)
- Excel (.xlsx)

## Required fields

Include the following columns (case-insensitive):

- `contract_code`
- `period_start_date`
- `period_end_date`
- `labor_cost`
- `material_cost`
- `overhead_cost`

## Recommended fields

- `notes`
- `cost_category`

## Upload steps

1. Open the contract and select **Import costs**.
2. Choose your file and confirm the field mapping.
3. Review the preview and submit.
4. Resolve any validation errors before re-uploading.

## Troubleshooting

- **Missing contract**: Ensure the `contract_code` matches an existing contract exactly.
- **Date errors**: Use ISO format (`YYYY-MM-DD`) for period dates.
- **Negative costs**: Costs must be zero or greater.

## Related guides

- [Import milestones](/docs/import-milestones)
- [Import delivery units](/docs/import-delivery-units)
