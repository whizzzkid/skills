---
class: principle
---

- **Rule:** When an In Review / Ready-for-Review ticket has a linked PR merged within 14 days, auto-transition it to Done and render it as a checked `[x]` auto-action — never an open `[ ]` TODO.
- **Why:** Surfacing an already-finished ticket as a user TODO is noise; the loop between PR merge and ticket status should close automatically.
- **Where:** start Stage 2b (Auto-transition merged-PR tickets); `## 🤖 Auto-Actions` section.
