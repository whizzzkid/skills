---
skill: wk-pr
date: 2026-07-23
type: correction
severity: high
---

Communicated a wrong merge order for a PR stack by deriving it from part-N labels/memory instead of the PRs' actual base branches.

**What happened:** Asked for the merge order of a 6-PR stack, the agent produced a graph from the `part-N/6` labels and its mental model. It stated `#B → #C` and `#B → #F` dependencies that did not exist — both C and F were based on the trunk, not on B — and posted this incorrect order to a team channel.

**Root cause:** Merge order was inferred from ordinal labels and recollection rather than read from ground truth. A stack's real dependency graph lives only in each PR's `baseRefName`.

**Suggested fix:** Before ever stating or posting a stack's merge/dependency order, query every PR's base: `gh pr view <n> --json number,headRefName,baseRefName`. Build the order strictly from `base` edges (trunk-based PRs are independent; a PR merges only after the PR owning its base branch). Never infer order from part-N labels, titles, or memory.
