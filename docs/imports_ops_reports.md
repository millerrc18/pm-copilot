---
title: "Operations Imports"
summary: "Import IFS reports for procurement, production, efficiency, quality, and BOM analysis."
last_updated: "2026-02-05"
category: "Operations"
---

# Operations Imports

Operations imports accept IFS exports in spreadsheet form. Each import is program scoped and recorded in the import history table.

## Supported reports

- Materials
- Shop Orders
- Shop Order Operations
- Historical Efficiency
- Scrap
- MRB Part Details
- MRB Disposition Lines
- BOM

## Import steps

1. Download the template for the report you plan to import.
2. Align the IFS export headers with the template column names.
3. Upload the file from the Operations Imports page.
4. Review the import history table for status and row counts.

## Idempotence

Duplicate files are blocked by checksum. To reimport corrected data, delete the prior import and upload the new file.
