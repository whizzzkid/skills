---
class: principle
---

# Honor the current task branch

- **Rule:** Treat the user's existing dedicated task branch as authoritative;
  create another only when the current checkout is unsuitable or the user asks
  for additional isolation.
- **Why:** Repository branching defaults do not override the workspace choice
  the user already made.
- **Where:** [`wk-workflow`](../README.md) Phase 5 repository preflight.
