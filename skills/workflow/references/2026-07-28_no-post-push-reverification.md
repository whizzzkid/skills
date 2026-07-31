---
class: principle
---

# Do not repeat known verification

- **Rule:** Run local verification before push. After pushing the same SHA, use
  pre-push exit status plus CI as evidence; repeat locally only after a new
  commit or to reproduce a CI failure.
- **Why:** Re-running a gate whose input and result are unchanged produces no
  new information.
- **Where:** [`wk-workflow`](../README.md) Phase 6 CI monitoring.
