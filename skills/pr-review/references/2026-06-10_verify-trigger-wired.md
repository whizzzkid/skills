---
class: principle
date: 2026-06-10
severity: medium
---

- **Rule:** During Phase 4 bot-finding validation, after reproducing the
  mechanism, grep for the trigger that activates the affected path (env var in
  compose/CI, live caller, prod config) before accepting severity. Dormant path
  → "Confirmed but narrower than stated", not Blocker.
- **Why:** Bots fire on static mismatches without checking reachability;
  accepting verbatim over-escalates latent forward-compat gaps to merge blockers.
- **Where:** Phase 3 bot-findings validation queue — "Verify the path is wired".
