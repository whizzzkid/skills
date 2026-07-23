---
skill: wk-pr-break
date: 2026-07-23
type: gap
severity: high
---

After re-parenting one part of a PR stack onto another to fix ordering, the part-N numeric labels no longer matched merge order and became a misleading source of truth.

**What happened:** A gate PR (`part-3`) was re-parented onto its data-provider PR (`part-4`) via `git rebase --onto` to fix a stack-ordering bug, so `part-4` now merges before `part-3`. The ordinal `part-N/6` labels were left unchanged, implying a sequential order that contradicted the actual base graph, and later drove a wrong merge-order statement.

**Root cause:** The skill slices and labels by ordinal but has no step to reconcile labels when the dependency graph is reordered after creation. Ordinal labels imply a total order the base graph may not honor.

**Suggested fix:** When any part is re-parented after creation, either renumber the part-N labels to match the new topological order, or drop ordinal labels and instead state each PR's parent explicitly (e.g. "base: <branch>"). Add a post-reorder check: confirm the ordinal sequence still matches `baseRefName` edges; if not, fix the labels in the same step.
