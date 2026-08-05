---
skill: wk-pr-update
date: 2026-08-05
type: gap
severity: medium
verified-against-source: yes
---

Detect sequential identifier collisions before merging an updated base through a documentation stack.

**What happened:** A base branch and a stacked documentation branch independently assigned the same next architecture-decision number, so the top merge required a rename and reference reconciliation.

**Root cause:** The update workflow checked textual conflicts and branch topology but did not compare newly allocated sequential identifiers across both histories before propagation.

**Suggested fix:** Before merging a base into a documentation stack, scan both sides for newly allocated ADR, migration, or schema identifiers and assign the stacked artifact the next free identifier before completing the merge.
