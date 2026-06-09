---
class: principle
skill: wk-adversarial-review
date: 2026-06-09
severity: medium
---

- **Rule:** Flag `curl -s` (without `-S`) whose response is later parsed for
  errors; require `-sS` plus an exit-status check.
- **Why:** `-s` suppresses curl's transport diagnostics (DNS/TLS/refused) and
  leaves stdout empty, so the body-error parser prints a misleading
  empty-reason message instead of the real network failure.
- **Where:** Sweep 2.29 (curl silent-mode transport-error sweep).
