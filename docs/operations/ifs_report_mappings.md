# IFS Report Mappings

This mapping is the baseline reference for Operations imports. It captures expected tabs, key fields, and joins from common IFS exports. Validate each tab against actual exports before finalizing importer headers.

## Shared conventions

- Program is required for every import and becomes the top level scope in the app.
- Row keys should be stable and based on business identifiers when present.
- Date fields should be parsed into ISO dates. Invalid dates should be rejected with row level errors.
- Numeric measures should default to zero only when the source is blank, not when the source is invalid.

## Materials report

Expected tab name: `Materials`

- Primary key candidates
  - Part number plus supplier plus order number
  - Part number plus supplier plus receipt date
- Date fields
  - Order date
  - Need date
  - Receipt date
- Numeric measures
  - Quantity ordered
  - Quantity received
  - Unit cost
  - Extended cost
  - Lead time days
- Join keys
  - Part number
  - Supplier
  - Purchase order
  - Buyer
- Filter dimensions
  - Supplier
  - Commodity
  - Buyer
  - Part number
  - Date range

## Shop Orders report

Expected tab name: `ShopOrders`

- Primary key candidates
  - Shop order number
  - Shop order number plus release number
- Date fields
  - Planned start
  - Planned finish
  - Actual start
  - Actual finish
  - Due date
- Numeric measures
  - Order quantity
  - Quantity completed
  - Remaining quantity
  - Estimated hours
  - Actual hours
- Join keys
  - Shop order number
  - Part number
  - Work center
- Filter dimensions
  - Status
  - Work center
  - Part number
  - Date range

## Shop Order Operations report

Expected tab name: `ShopOrderOperations`

- Primary key candidates
  - Shop order number plus operation number
  - Shop order number plus operation sequence
- Date fields
  - Operation start
  - Operation finish
  - Scheduled start
  - Scheduled finish
- Numeric measures
  - Setup hours
  - Run hours
  - Actual labor hours
  - Queue time
- Join keys
  - Shop order number
  - Operation number
  - Work center
- Filter dimensions
  - Status
  - Work center
  - Operation number
  - Date range

## Historical Efficiency report

Expected tab name: `HistoricalEfficiency`

- Primary key candidates
  - Period start date plus labor category
  - Work center plus period start date
- Date fields
  - Period start
  - Period end
- Numeric measures
  - Planned hours
  - Actual hours
  - Variance hours
  - Efficiency percent
- Join keys
  - Work center
  - Labor category
- Filter dimensions
  - Labor category
  - Work center
  - Date range

## Scrap report

Expected tab name: `Scrap`

- Primary key candidates
  - Scrap transaction id
  - Shop order number plus scrap date plus part number
- Date fields
  - Scrap date
  - Transaction date
- Numeric measures
  - Scrap quantity
  - Scrap cost
- Join keys
  - Part number
  - Reason code
  - Shop order number
- Filter dimensions
  - Reason code
  - Part number
  - Date range

## MRB Part Details report

Expected tab name: `MRBPartDetails`

- Primary key candidates
  - MRB number plus line number
  - MRB case id
- Date fields
  - MRB created date
  - MRB closed date
- Numeric measures
  - MRB quantity
  - Unit cost
  - Extended cost
- Join keys
  - Part number
  - MRB number
  - Supplier
- Filter dimensions
  - Status
  - Disposition
  - Part number
  - Date range

## MRB Disposition Lines report

Expected tab name: `MRBDispoLines`

- Primary key candidates
  - MRB number plus disposition line number
- Date fields
  - Disposition date
- Numeric measures
  - Disposition quantity
  - Disposition cost
- Join keys
  - MRB number
  - Disposition
  - Responsible
- Filter dimensions
  - Disposition
  - Responsible
  - Date range

## BOM Indented report

Expected tab name: `BOMIndented`

- Primary key candidates
  - Parent part number plus component part number plus line number
- Date fields
  - Effective from
  - Effective to
- Numeric measures
  - Quantity per
  - Yield percent
- Join keys
  - Parent part number
  - Component part number
- Filter dimensions
  - Parent part number
  - Component part number
  - Effectivity date

## BOM Structure report

Expected tab name: `BOMStructure`

- Primary key candidates
  - Parent part number plus component part number plus level
- Date fields
  - Effective from
  - Effective to
- Numeric measures
  - Quantity per
- Join keys
  - Parent part number
  - Component part number
- Filter dimensions
  - Parent part number
  - Component part number
  - Effectivity date

## Validation checklist for each tab

- Confirm the tab name and required headers in the actual export.
- Identify stable business keys for idempotent imports.
- Verify the date columns are consistent across exports.
- Capture any additional dimensions that should appear in filter bars.
