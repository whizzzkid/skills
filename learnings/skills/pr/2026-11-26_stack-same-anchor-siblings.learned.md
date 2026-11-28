---
skill: wk-pr
date: 2026-11-26
type: pattern
severity: low
verified-against-source: n/a
---

Sibling PRs that insert at the same anchor → offer stacking the later PR on the earlier one as an alternative to
"merge order + update later".

**What happened:** Two PRs opened in one session both inserted at the same anchor (same list position in a shared
file). Stacking the later PR on the earlier one's branch, then merging the parent into it once when the parent
changed, kept each PR's diff scoped to its own change. The final merge to the default branch was then one-sided, with
no conflict to resolve.

**Root cause:** The sibling-PR rule in `wk-pr` (intersect changed-file sets → state merge order + expected conflict
files → offer `wk-pr-update` after the earlier merge) handles generic file overlap. It has no stacking option. When
the overlap is at the same insertion anchor, the conflict is certain, not just possible, and deferring it to
post-merge resolution is strictly worse than stacking up front.

**Suggested fix:** In the sibling-PR overlap rule, add a branch: overlap at the same insertion anchor (not merely the
same file) → recommend stacking the later PR on the earlier one (branch from its head per the existing "new layer"
rule, set `baseRefName` to the parent branch) and merge the parent in once on update, instead of resolving the
conflict after the first merge.
