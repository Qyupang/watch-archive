# Watch Archive agent guidance

## Project context

- Watch Archive is a static HTML/CSS/JavaScript PWA hosted on GitHub Pages. It is not a Remix, React, or native Apple app.
- Preserve the existing editorial identity: ivory and black palette, restrained typography, clear hierarchy, and the established mobile-first layouts. See `UI_QUALITY_GUIDELINES.md` for project-specific design and behavior requirements.
- Prefer small, targeted changes. Preserve existing features, navigation, scroll restoration, image handling, and owned/selling/sold/archive states unless the user explicitly requests a behavior change.
- Do not make important database/schema changes or delete database data without the user's prior approval.

## Apple Design reviews

- For UI/UX reviews, audits, or design improvement requests, follow `.design-rules/SKILL.md` and load the relevant `.design-rules/references/hig/*.md` files before giving feedback. Follow the skill's instruction to read the always-load references and only the additional pages relevant to the screen; do not load the entire reference directory.
- Translate applicable HIG principles to a browser-based mobile PWA. Do not apply native-only API, App Store, Liquid Glass, or other platform-specific guidance unless the feature actually uses it. When Apple has no direct web equivalent, label the recommendation as a design judgment.
- Use the existing Watch Archive design and `UI_QUALITY_GUIDELINES.md` as the product baseline. HIG reviews should identify concrete usability, accessibility, and platform-fit improvements without flattening the product's visual identity.
- Separate review from implementation: when asked to review, report findings and proposed fixes without changing code. When asked to improve a screen, make the smallest requested change and preserve unrelated behavior.
- Cite each HIG finding with its reference filename and heading, as required by `.design-rules/SKILL.md`.
