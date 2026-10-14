# Watch Archive V6

## Commit message
`feat: add daily inspiration from archive photos`

## Changes
- Added a Daily Inspiration section to the main screen.
- Selects one photo from Archive entries each day.
- Selection is deterministic for the current date, so the same photo remains during the day.
- Uses all photos saved under Archive entries, not only cover photos.
- Tapping the image opens the full-screen photo viewer at that photo.
- Tapping the metadata opens the corresponding watch detail page.
- If there are no Archive photos, the section is hidden.

Local-first · No Supabase required

## V7
- Fix multi-digit size input
- Normalize size to mm on blur/save
- Swipe left/right between watches in detail view
- Add Previous/Next buttons

## V8
- Fix detail-page hero image natural-size overflow on mobile
- Constrain main photo height and preserve full image with contain

## V9 — Watch records and maintenance history
- Added purchase date, purchase reason, and purchase-price records to watch entries.
- Added sale status, sale date, sale price, and sale reason for sold watches.
- Added a combined chronological Watch Life Timeline with purchase and sale events grouped by year.
- Added yearly purchase totals and sale totals when applicable.
- Added overhaul date and repair-history records for watches still owned.
- Repair history supports date, cost, and notes, with repair count and cumulative repair cost calculated automatically.
- Added maintenance summaries to watch details, including the latest maintenance date and repair-cost totals.
- Sold watches no longer show overhaul and repair-history inputs in the editor.
- Existing maintenance records are retained when those fields are hidden.

## V10 — Mobile editor and layout improvements
- Prevented the watch editor and its input fields from extending beyond the mobile viewport.
- Improved mobile date-field sizing and centered the displayed date text.
- Placed purchase and sale dates side by side for sold watches.
- Kept purchase and sale price fields aligned in the same two-column layout.
- Grouped editor fields into visual sections:
  - Watch basics: brand, model, reference, size, and movement.
  - Purchase and sale records: ownership status, dates, prices, and reasons.
  - Maintenance history: overhaul date and repair records, for watches not marked as sold.
  - Personal records: tags and notes.
  - Photo management: per-photo type and notes.
- Added restrained section headings and divider lines to keep the existing minimal theme.

## V11 — Photo loading improvements
- Added progressive loading to the Photos page, displaying photos in batches rather than rendering the entire gallery at once.
- Added automatic loading of the next batch when the user approaches the end of the gallery, while retaining a manual load-more button.
- Replaced the circular photo-loading spinner on watch cards with a minimal watch-dial and rotating-second-hand animation.
- Respects the device's reduced-motion preference by slowing the animation.

## Recent implementation notes
- The deployed site is hosted on GitHub Pages.
- Some changes were committed to the repository but have not yet been verified on a physical iPhone/Safari device.

