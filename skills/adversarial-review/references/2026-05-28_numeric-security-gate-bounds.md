---
class: principle
date: 2026-05-28
source:
  - learnings/skills/adversarial-review/2026-05-28_max-lines-no-upper-bound.md
severity: high
---

- **Rule** — a numeric config field that gates a security control must enforce both a positive lower bound and a hard ceiling; flag a missing ceiling as a blocker.
- **Why** — without an upper bound an operator sets the value arbitrarily high and bypasses the gate entirely (e.g., a LOC-approval ceiling set to 999999 disables the gate); the existing sweeps had no pattern for this class.
- **Where** — new sweep 2.21 (Numeric security-gate bounds) in wk-adversarial-review Step 2.
