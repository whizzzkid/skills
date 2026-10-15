---
class: principle
---

# A non-obvious workaround is a self-caught error

**Rule**

- Treat any tool, environment, or API failure that needed a non-obvious workaround as a live-capture trigger. Invoke
  `wk-learn` for the owning tool's skill in the same response.

**Why**

- A build-entitlement failure and an API 422 were each worked around mid-session but captured only at retro. The
  live-capture trigger said "self-caught error", and a workaround for someone else's failure didn't register as one.
  This is a scope gap in the trigger, not a re-violation, so it was widened instead of escalated.

**Where**

`skills/workflow/SKILL.md` → HARD RULE — live learning capture.
