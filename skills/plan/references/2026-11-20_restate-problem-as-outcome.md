---
class: principle
skill: wk-plan
date: 2026-11-20
---

# Check the plan against the ticket's stated outcome

- **Rule:** A gap found mid-work that defeats the ticket's stated outcome is in scope: fix it or ask, never defer it on
  your own. `wk-plan` Step 4 restates the ticket's problem as a post-merge outcome and checks the plan achieves it.
- **Why:** A ticket framed its problem as "CI never lints these files", but its task bullets named only a config
  include list. The agent found CI ran no lint step at all, did the bullets, and listed the CI step as a follow-up, so
  the merged change would still leave the files unlinted. Reading task bullets as the full scope, unchecked against
  the problem statement, ships a change that does not deliver the ticket.
- **Where:** `SKILL.md` → Step 4 validation; the mid-work scope rule lives in `wk-workflow` Continuity.
