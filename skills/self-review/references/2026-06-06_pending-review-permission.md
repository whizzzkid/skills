---
class: principle
---

- **Rule:** Pre-flight the pending-review POST permission
  (`gh api repos/*/pulls/*/reviews`) before building the review payload.
- **Why:** Auto-mode permission classifier blocks GitHub writes under the
  user's identity; without an early check it blocks at the POST, after the
  payload work is wasted.
- **Where:** Step 0.5 (between Step 0 routing and Step 1 gather context).
