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
