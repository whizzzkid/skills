---
class: principle
source: learnings/skills/pr-resolve/2026-08-26_stopped-before-ready.md
---

# Hard Rule 1 gates push, not post-push tail steps

After push + reply (Step 8), Steps 9–11 (merge conflict check, mark ready,
CI wait, learnings, retro) are autonomous. Stopping for confirmation after an
already-authorized push breaks the workflow's "no early return" principle.

The only valid post-push stops are:
- CI failing after 3 fix-loop attempts
- A blocked adversarial-review verdict
- Explicit user interjection

Hard Rule 1's scope is the push itself — it does not extend to the Steps
that follow it.
