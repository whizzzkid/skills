---
skill: wk-pr-review
date: 2026-11-13
type: pattern
severity: low
verified-against-source: n/a
---

For stacked PRs whose parent merged into an intermediate branch, confirm the parent's merge commit reached the PR base.

**What happened:** A parent part was merged into the grandparent branch rather than the default branch; the child now targets the default branch. `git merge-base --is-ancestor <parent-merge> origin/<base>` confirmed the content landed, so the three-dot diff was scoped correctly.

**Root cause:** Stack merges can strand a part on a dead intermediate branch, inflating or mis-scoping the child's diff.

**Suggested fix:** In Phase 1 "related PRs", for each merged stack parent check its merge commit is an ancestor of the PR base; if not, flag that the child's diff carries the parent's changes.
