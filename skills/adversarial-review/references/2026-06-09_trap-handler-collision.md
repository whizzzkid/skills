---
class: principle
skill: wk-adversarial-review
date: 2026-06-09
severity: high
---

- **Rule:** When the diff adds `trap '...' <signals>`, grep the whole file
  for other `trap` calls sharing any signal; two traps on one signal is a
  blocker.
- **Why:** `bash trap` REPLACES the prior handler — it does not append — so a
  second trap silently disables the first's cleanup. Visible only in a
  whole-file view, not the hunk; fixes in separate rounds each look correct.
- **Where:** Sweep 2.25 (Trap-handler collision sweep).
