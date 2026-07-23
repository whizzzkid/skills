---
class: principle
---

# Read a stack's merge order from `baseRefName`, never `part-N` labels

**Rule** — Before stating or posting a stack's merge/dependency order, query
each PR's base (`gh pr view <n> --json headRefName,baseRefName`) and build the
order strictly from base edges: a trunk-based PR is independent; a PR merges
only after the PR owning its base. Never infer order from `part-N` title labels
or recollection — labels drift after any re-parent and fabricate dependencies
that never existed.

**Why** — asked for a 6-PR stack's merge order, an agent produced the graph from
`part-N/N` labels and mental model, stated two dependencies (`#B → #C`,
`#B → #F`) that did not exist — both C and F were trunk-based — and posted the
wrong order to a team channel. The real dependency graph lives only in each PR's
`baseRefName`.

**Where** — Step 2 stacking, and any point that communicates a stack's order.
