# Watch Archive UI Quality Guidelines

These guidelines adapt the relevant ideas from [emilkowalski/skills](https://github.com/emilkowalski/skills) to Watch Archive. They are project-specific implementation and review criteria, not a dependency or runtime library.

## Design principles

- Preserve Watch Archive's classic editorial identity: ivory/black palette, restrained typography, clear hierarchy, and minimal decoration.
- Preserve existing product behavior unless a change is explicitly requested. In particular, protect tab-specific scroll restoration, bottom navigation, watch editing/saving, image handling, and selling/owned/archive states.
- Prefer small, targeted changes over broad rewrites. Avoid adding a dependency when CSS or a small JavaScript change is sufficient.
- Every animation must communicate feedback or spatial/state change. Keep frequent interactions immediate and subtle; avoid animating routine navigation just for decoration.
- Use explicit transition properties rather than `transition: all`. Prefer short ease-out transitions for entering UI and honor reduced-motion preferences.
- Gate hover-only styling behind capability queries such as `@media (hover: hover) and (pointer: fine)`. Touch interactions still need clear active/pressed feedback.
- Never disable browser zoom. For iOS form zoom, verify input sizing and only apply a 16px minimum where needed without unnecessarily changing the visual hierarchy.

## Mobile and PWA review

- Check safe-area insets for fixed navigation, floating actions, sheets, and bottom actions.
- Prefer `dvh` for app-height layouts and use stable viewport units where appropriate; test the browser chrome expanding/collapsing.
- Keep nested scrolling intentional. Sheets and menus should contain their own scroll without unexpectedly moving the page behind them.
- Ensure tappable controls have visible feedback, appropriate target sizes, and keyboard focus states.
- Verify that file selection, date inputs, number inputs, and the on-screen keyboard work in iOS Safari and when installed as a PWA.
- Do not treat desktop device emulation as proof of mobile correctness. Test on a real iPhone before declaring mobile fixes complete.

## Watch Archive edge-case checklist

Test at least these cases on relevant screens:

- No watches, one watch, and a large collection.
- Missing image, failed image load, and multiple photos.
- Long brand/model/reference names and Korean text.
- Missing optional values, zero values, and large purchase/customs/sale amounts.
- Owned, selling, sold, and archive states.
- Empty search results and filters with zero matches.
- Slow or failed save/upload, with an explicit failure state and preserved user input.
- Keyboard open while editing; sheet content and save action remain reachable.
- Tab switching restores the intended scroll position, while newly selected tabs follow the expected scroll behavior.
- Light/dark mode, narrow screens, safe-area insets, and reduced-motion settings.

## Change workflow

1. Identify the relevant screen, data boundary, and current behavior before editing.
2. Record the expected before/after behavior and avoid unrelated refactors.
3. Make the smallest change that solves the verified problem.
4. Review the diff for accidental behavior changes and check console/runtime errors where possible.
5. Verify desktop and real-device behavior when the change affects mobile layout or gestures.
6. Report what was changed, what was tested, and what still requires real-device verification.

## Scope

The first pass adds a global tap-highlight reset, manipulation-friendly touch handling for controls, and visible keyboard focus. These are low-risk baseline improvements. It does not claim that every screen has been fully audited or that real-device testing has been completed.
