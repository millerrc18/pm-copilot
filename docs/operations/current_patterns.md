# Current Repo Patterns for Operations

This summary captures existing patterns that should be reused for Operations work.

## Import services

- Cost import uses `CostImportService` with required headers and row level validation plus a transaction based create flow.
- Milestones and delivery units use similar service patterns with `MilestoneImportService` and `DeliveryUnitImportService`.
- Contract period imports use `ContractWorkbookImporter` for multi sheet XLSX with a per sheet required header list.
- Import templates are generated dynamically via `ImportTemplateBuilder` and `ImportTemplatesController`.

## Saved views

- Cost Hub, Risks, and Planning Hub each have saved view controllers.
- Saved views store filter params and can reset to defaults.
- Views render save or reset controls directly in the filter section.

## Charts

- Charts are rendered with Chart.js via `app/javascript/controllers/chart_controller.js`.
- Chart data is passed through data attributes for labels and datasets.
- Shared UI cards support a chart variant.

## Table layout and styling

- Tables are constructed directly in views with Tailwind utility classes.
- Cost Hub and Risks pages use sortable columns and summary rows in the same table section.
- Filter and summary card layouts are custom in each view rather than shared partials today.

## Guidance for Operations work

- Prefer the existing import service pattern with required headers and row level error reporting.
- Reuse the saved view controller flow and data storage for Operations pages.
- Keep chart data in controller view models and pass datasets through data attributes.
- Use Tailwind table utility classes consistent with the Cost Hub and Risks layouts.
