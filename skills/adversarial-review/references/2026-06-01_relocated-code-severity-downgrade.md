---
class: principle
skill: wk-adversarial-review
date: 2026-06-01
severity: medium
---

- **Rule:** In a movement-dominated diff, before rating a finding a
  blocker, check whether the flagged line existed verbatim at
  `$MERGE_BASE`; if relocated-unchanged, downgrade to suggestion or skip.
- **Exception (2026-07-28):** the downgrade does **not** apply when the diff
  *deleted* the alternative that was masking the defect. A deletion changes a
  survivor's criticality without changing its text, so "unchanged at
  `$MERGE_BASE`" is true and irrelevant — the diff is what made the surviving
  path load-bearing. Sweep 2.4 and the subagent's "Relocation-aware" bullet both
  carry the carve-out. Amended in place rather than left as a blanket rule: a
  stale unconditional downgrade gets either wrongly obeyed or wrongly ignored.
- **Why:** A pure move makes pre-existing, already-accepted code look
  net-new; the subagent otherwise bills the refactor for inherited debt
  it neither introduced nor modified.
- **Where:** Step 1 (annotate net-new vs relocated) + subagent
  "Relocation-aware" severity bullet. [[2026-06-01_rename-triggers-enumeration-sweep]]
