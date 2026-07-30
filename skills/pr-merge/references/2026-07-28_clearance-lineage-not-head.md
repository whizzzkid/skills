---
class: principle
skill: wk-pr-merge
date: 2026-07-28
severity: medium
---

# Merge consumes clearance lineage, not SHA equality

- **Rule:** Merge reads the completion gate's clearance and never dispatches
  review. Direct finding-response commits and tree-identical history rewrites
  preserve clearance; genuinely new work returns to the completion gate.
- **Why:** HEAD equality made a reviewed typo or requested mechanical fix demand
  another full gate, creating a review-fix-review loop.
- **Verification:** Source history confirmed the SHA gate predated the report;
  a later ownership fold still left merge dispatching on stale records.
- **Escalation:** Replace merge-side dispatch with a record-only lineage check.
- **Where:** [`wk-pr-merge`](../README.md) Step 5.5.
- **Budget:** Step 5.5 replacement is -61 bytes:
  22,974 → 22,913 of 24,576.
