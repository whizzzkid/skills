---
class: principle
skill: wk-adversarial-review
date: 2026-06-01
severity: medium
---

- **Rule:** In a movement-dominated diff, before rating a finding a
  blocker, check whether the flagged line existed verbatim at
  `$MERGE_BASE`; if relocated-unchanged, downgrade to suggestion or skip.
- **Why:** A pure move makes pre-existing, already-accepted code look
  net-new; the subagent otherwise bills the refactor for inherited debt
  it neither introduced nor modified.
- **Where:** Step 1 (annotate net-new vs relocated) + subagent
  "Relocation-aware" severity bullet. [[2026-06-01_rename-triggers-enumeration-sweep]]
