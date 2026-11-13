---
class: principle
---

# A merged stack parent must reach the child's base

- **Rule:** For each merged stack parent, check `git merge-base --is-ancestor <parent-merge> origin/<base>`. Not an
  ancestor → the parent merged into an intermediate branch that never reached the base; the child's diff then carries
  the parent's changes. Scope review to the child's own commits and flag the stranded parent.
- **Why:** A parent part merged into the grandparent branch instead of the default branch while the child retargeted
  the default branch. The ancestry check confirmed the content landed, so the diff was scoped correctly — without it, a
  stranded parent silently inflates or mis-scopes the child's diff.
- **Where:** [`wk-pr-review`](../README.md) → Phase 1, Claims → related PRs.
