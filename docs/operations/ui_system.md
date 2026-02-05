# Operations UI System

This document defines the shared UI patterns for Operations pages. The intent is consistent behavior across procurement, production, efficiency, quality, and BOM pages.

## Filter bar

Layout:

- Program selector on the left, required and always visible.
- Date range selector next, when the data includes dates.
- Page specific filters in a second row on small screens, same row on desktop.
- Saved views control aligned to the right.

Behavior:

- Filters are applied with Turbo frame updates, not full page reloads.
- Filters are represented in query params so saved views can store them.
- Clear filters resets to defaults defined per page.

## Applied filters summary

- Display a compact list of active filters under the bar.
- Each filter is removable with a single action.
- The summary hides when only defaults are applied.

## Saved views

- Saved views are per user and per page key.
- Users can save, update, or set a default.
- Default view applies automatically on page load.
- Managing saved views is accessible from the same dropdown.

## Summary cards

- Use a consistent grid with four cards on desktop, two on tablet, one on mobile.
- Each card includes a label, value, and optional trend indicator.
- Cards should handle zero or missing values with a clear fallback label such as N A or none.

## Charts

- Limit to two or three charts per page to avoid clutter.
- Use consistent color tokens for categories across pages.
- Charts should render inside responsive containers with a minimum height.
- Show an inline empty state when there is no data for the current filter set.

## Tables

- Use shared table styles and sticky headers where possible.
- Default sort should match the page primary insight, such as spend descending.
- Include a no data row when filters return no records.

## Empty, loading, and error states

- Empty state: short headline, one sentence guidance, and optional reset filters action.
- Loading state: skeleton rows or spinners inside the panel.
- Error state: highlight the failed panel with a retry action where possible.

## Mobile behavior

- Filter bar stacks into two rows on iPhone.
- Summary cards collapse to a single column.
- Tables allow horizontal scroll but preserve headers and row readability.
- Drawers or detail panels use full screen overlays on mobile.

## Accessibility

- Labels must be connected to inputs.
- Buttons must include accessible names.
- Color usage must meet contrast guidelines in both light and dark themes.
