---
title: Importing milestones
summary: Upload delivery milestone data with required fields and error recovery steps.
last_updated: 2025-02-14
category: Imports
---

# Importing milestones

Milestone imports keep promise dates and completion status aligned with delivery schedules.

## Supported file formats

- CSV (.csv)
- Excel (.xlsx)

## Required fields

Include the following columns:

- `contract_code`
- `milestone_name`
- `due_date`
- `status`

## Accepted status values

- `planned`
- `in_progress`
- `complete`
- `blocked`

## Upload steps

1. Open the contract and select **Import milestones**.
2. Choose the file and map columns.
3. Validate the preview data.
4. Submit to create or update milestones.

## Troubleshooting

- **Invalid status**: Use one of the accepted status values.
- **Duplicate milestones**: Ensure `milestone_name` is unique per contract.
- **Date format**: Use `YYYY-MM-DD` for `due_date`.

## Related guides

- [Import costs](/docs/import-costs)
- [Import delivery units](/docs/import-delivery-units)
