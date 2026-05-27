---
class: principle
date: 2026-05-20
severity: medium
---

- **Rule:** Track `(path_prefix, concern_class)` across bot review rounds; after 3 re-fires of the same pair, stop and ask the user (investigate / defer / dismiss).
- **Why:** Three identical re-fires signals a wrong fix, a stale bot snapshot, or a structural concern — silent loop continuation wastes cycles.
- **Where:** Step 4 — new "Detect bot re-review thrash" HARD RULE before the order-of-processing paragraph.
