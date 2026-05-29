---
class: principle
skill: wk-retro
date: 2026-05-29
---

# Retro log: Session-N findings only, log only when actionable

- **Rule:** Retro entries are headed `## Session-N` (no timestamp, no task/topic,
  no work narrative) with two buckets — **What worked** and **What could've been
  better**. Write an entry only when ≥1 actionable skill-gap surfaced; otherwise
  write nothing.
- **Why:** Timestamps and activity narrative leak when/what was worked on and add
  no reusable value; padding the log to mark that a session ran defeats its
  purpose. The log should shrink as the system matures.
- **Where:** Step 3 — three HARD RULEs (log-only-if-actionable, no
  timestamps/narrative + `Session-N`, two-bucket format) + validation gate
  (rejects time-of-day stamps).
