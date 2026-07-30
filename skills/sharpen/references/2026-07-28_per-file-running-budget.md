---
class: principle
skill: wk-sharpen
date: 2026-07-28
severity: medium
---

# Keep one byte ledger per touched skill

- **Rule:** Measure every touched `SKILL.md` at entry and debit every edit group
  before editing that file again. No ledger entry means the file is unbudgeted.
- **Why:** Pair-level invalidation already existed, yet small tail edits drifted
  two files over the ceiling because no control accumulated their total.
- **Verification:** The void-on-revision clause predated this report; source and
  history confirmed it had no per-file or whole-pass scope.
- **Escalation:** Replace the pair-level prose warning with a running structural
  ledger; keep detailed mechanics in
  [`byte-budget.md`](byte-budget.md#keep-one-running-ledger-per-touched-file).
- **Where:** [`wk-sharpen`](../README.md) Step 7.5.
- **Budget:** Exact replacement is +45 bytes: 24,407 → 24,452 of 24,576.
  Initial headroom 169 ≥ twice the addition, so no reclaim is owed.
