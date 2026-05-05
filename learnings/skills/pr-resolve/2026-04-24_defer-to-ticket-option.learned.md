---
skill: wk-pr-resolve
date: 2026-04-24
type: gap
severity: medium
---

No documented path for deferring a finding to a follow-up ticket.

**What happened:** User wanted to defer a regex consolidation finding to a Jira ticket (BOARD-NUM) rather than fix in-PR. Current skill only offers apply/edit/dismiss/skip/rethink. Had to improvise: ask for ticket URL, post as reply, resolve thread.

**Root cause:** Skill triage options don't include a "defer" path with ticket tracking.

**Suggested fix:** Add `(t) Defer to ticket` as a named option in Step 5. When selected: ask for URL, record in `deferrals`, draft reply as "Tracked in [TICKET](url)", mark for resolve_after_push.
