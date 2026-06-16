---
class: principle
date: 2026-06-12
---

# Routing claims must be cross-checked against authoritative reviewer statements

**Rule:** When a diff adds a claim about implementation routing (which method a
gate calls, which path bypasses a hook), grep the PR's review thread for
reviewer statements describing the same routing. Any contradiction between the
new claim and a reviewer's direct assertion about the code is a blocker.

**Why:** A reviewer who has read the source is ground truth; a spec author
inferring routing from logic is not. Logical inference silently contradicted an
authoritative reviewer comment and went undetected until adversarial re-review.

**Where:** Step 2 Mechanical Sweep Catalog, row 2.34.
