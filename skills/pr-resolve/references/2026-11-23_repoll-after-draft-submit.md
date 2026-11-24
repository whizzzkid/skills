---
class: principle
source: learnings/skills/pr-resolve/2026-11-23_repoll-after-draft-submit.learned.md
date: 2026-11-23
severity: medium
---

## Re-check deferred thread actions once the user's draft is submitted

- **Rule:** A reaction or resolve deferred because its reply sits in the user's pending review is live work. On every
  status report, re-query that reply's `state`; once it reads `SUBMITTED`, react and resolve in the same turn without
  being asked.
- **Why:** The deferral was recorded but never re-checked. The next status report listed the thread as the user's open
  work after they had already submitted the draft, so the thread stayed unreacted and unresolved.
- **Where:** `SKILL.md` Steps 7–8.
