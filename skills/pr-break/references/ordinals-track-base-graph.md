---
class: principle
---

# Ordinal `part-N` labels must track the base graph

**Rule** — Reordering a stack after its PRs exist (`git rebase --onto` to
re-parent a child) invalidates the `part-N/M` ordinals: they keep asserting a
merge order the base graph no longer honors, turning a helper label into an
actively-misleading source of truth. In the same step, either renumber the
labels to the new topological order, or drop ordinal labels and state each PR's
parent explicitly (`base: <branch>`). Merge/dependency order is read only from
`baseRefName` edges (`gh pr view <n> --json headRefName,baseRefName`), never
from `part-N` labels or memory. After any re-parent, confirm the ordinal
sequence still matches the base graph and fix mismatches before stating the
order anywhere.

**Why** — a real run re-parented a later part onto an earlier one to fix a
stack-ordering bug; the stale ordinal labels then drove a wrong merge-order
statement. Ordinals imply a total order the base DAG may not honor.

**Where** — Stage 3 seam-quality probe (the `git rebase --onto` reorder path)
and any point that assigns or reads `part-N` labels.
