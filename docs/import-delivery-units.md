---
title: Importing delivery units
summary: Load shipment data for delivery units including dates, quantities, and issues.
last_updated: 2026-01-31
category: Imports
---

# Importing delivery units

Delivery unit imports capture shipment volume and timing for each contract.

![Delivery unit import flow](/assets/docs/imports-flow.svg)

## Supported file formats

- CSV (.csv)
- Excel (.xlsx)

## Required fields

Include the following columns:

- `contract_code`
- `delivery_unit_name`
- `ship_date`
- `quantity`

## Optional fields

- `status`
- `notes`

## Upload steps

1. Open the contract and select **Import delivery units**.
2. Upload the file and map fields.
3. Verify the preview totals.
4. Submit and review the delivery unit table.

## Troubleshooting

- **Missing ship date**: Provide `ship_date` for delivered units; leave blank for pending units.
- **Quantity errors**: Quantities must be positive integers.
- **Unrecognized contract**: Confirm the `contract_code` matches an existing contract.

## Related guides

- [Cost hub overview](/docs/cost-tracking)
- [Import milestones](/docs/import-milestones)
