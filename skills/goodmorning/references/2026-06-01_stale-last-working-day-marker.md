---
class: principle
skill: wk-goodmorning
date: 2026-06-01
severity: high
---

- **Rule:** After reading the `last_working_day` marker, cross-check it
  against intervening sitrep day dirs; a day with `morning.md` but no
  `evening.md` means goodevening was skipped — override "yesterday" to the
  most recent such day, but only for gaps of 1–3 days.
- **Why:** A frozen marker (goodevening never ran) silently anchors
  "yesterday" to a stale day, so the standup re-reports posted achievements
  and carry-overs miss the intervening day's work.
- **Where:** Stage 0 Bootstrap, "Determine dates and paths" — stale-marker
  cross-check block, immediately after the marker read.
- **Bound:** Skip the override past a genuine weekend/holiday (>3 calendar
  days); the stale marker is expected and correct there.
