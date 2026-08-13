---
class: principle
---

**Rule** — After a prior PR merges in the same session, branch the follow-up from
`origin/<default>` (fetch first), never from the stale local ref.

**Why** — A stale local default branch includes already-merged commits in the new
branch's history, inflating the PR diff and complicating review.

**Where** — `wk-workflow` Phase 5, "Repo convention before branching."
