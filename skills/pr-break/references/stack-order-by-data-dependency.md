---
class: principle
---

**Rule:** When slicing a stack, order PRs by data-dependency, not conceptual
layer. A PR that adds a gate / validation / enforcement which goes CI-red when
its required data is absent must be a **descendant** of the PR that provides
that data — never an ancestor.

**Why:** Conceptual layering (schema → enforcement → data) inverts the
data-dependency order: the enforcement PR fails CI in isolation because the
data it checks does not yet exist on its base. Fixing it after creation needs
`git rebase --onto` surgery to invert the parent/child relationship. Each PR
must pass CI on its own base.

**Where:** wk-pr-break Stage 3 seam-quality probe — the directionality question
added alongside the isolation (Invariant 2) checks.
