---
class: principle
date: 2026-06-09
severity: low
---

- **Rule:** Re-run every pre-push gate against final HEAD, not a mid-session
  snapshot; a file added after an earlier local lint run silently skips it.
- **Why:** A formatter (e.g. `gofmt -l`) only checks files present when it ran,
  so a late-added file fails CI even though "lint passed" earlier — common when
  introducing a new toolchain.
- **Where:** Phase 3 Verification — final-HEAD gate-rerun bullet.
