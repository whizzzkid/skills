---
class: principle
skill: wk-pr-review
date: 2026-06-01
severity: medium
---

- **Rule:** When the playground confirms a bot finding only for a subset
  of the case the bot implied, reply with a scope note —
  `Confirmed for the case where X; does not apply when Y` — instead of a
  silent skip.
- **Why:** Bot findings are written for maximum surface area; the
  playground often isolates the failure to a narrow edge. Treating it as
  fully confirmed over-amplifies the finding and misleads the author on
  fix scope.
- **Where:** Phase 5 → "Deduplicate against existing comments" outcome
  table → new "Confirmed but narrower than stated" row + reply-justified
  list. Consistent with the existing "new evidence that materially
  changes the bot's claim" reply rule.
