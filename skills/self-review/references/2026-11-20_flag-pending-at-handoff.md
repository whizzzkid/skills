---
class: principle
skill: wk-self-review
date: 2026-11-20
---

# Flag a pending self-review when handing a ready PR to the user

- **Rule:** When a ready PR is handed to the user, state how many self-review comments are still pending and that
  they need submitting before merge.
- **Why:** The self-review was staged as pending and re-staged after fixes, then the user merged outside the agent.
  Step 4.5 fires only when the agent performs the merge, so the notes went public only after merge.
- **Where:** `SKILL.md` → Step 4.5 (Merge-gate submission). Source: self-review learning and the session-8
  retrospect.
