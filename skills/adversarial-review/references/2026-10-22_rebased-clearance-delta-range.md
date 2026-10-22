---
class: principle
---

**Rule** — Resolve a lineage-break delta base by ancestry: cleared SHA not an ancestor of HEAD → diff from the rebased
copy of the last reviewed PR commit (patch-id, subject fallback); no copy → review the whole PR.

**Why** — Across a rebase, `git diff <cleared>..HEAD` spans every base-branch change, inflating a small delta into a
full-branch review.

**Where** — [`clearance-lineage.md`](clearance-lineage.md) "Resolve the delta base".
