---
class: principle
---

# Diagnose absent required contexts

- **Rule:** On a blocked merge with visible checks green, compute the active
  ruleset's required contexts minus the current HEAD rollup.
- **Why:** A required context can have no run and therefore no failing result;
  a failure-only scan cannot see the blocker.
- **Rejected:** Do not query classic branch protection as a ruleset substitute,
  request a non-collaborator integration as a reviewer, or invent a GraphQL
  rerun mutation. Use a documented integration trigger or hand the UI action to
  the user.
- **Where:** [`wk-gh`](../README.md) merge-readiness diagnostics.
