---
class: principle
---

- **Rule:** The `start` sweep must fold assigned items from every connected
  tracker (Jira, GitHub Issues, and any other with an available MCP) into one
  pending-on-me view — flag 🔁 status changes vs the previous `live.md`, flag
  ⏳ staleness (pending >7d), read each tracker's native priority/severity
  field, and sort each section by priority → staleness → due-date.
- **Why:** Surfacing tickets by due-date urgency alone hides high-priority and
  long-stalled work; a single-tracker sweep misses items the user is blocking
  in other systems.
- **Where:** wk-sitrep Stage 2 "Cross-tracker pending-on-me sweep" + the
  composite-sort bullet in the SilverBullet formatting HARD RULE.
