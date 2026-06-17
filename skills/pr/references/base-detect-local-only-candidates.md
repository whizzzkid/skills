---
skill: wk-pr
class: principle
---

**Rule** — A base candidate may be a local-only ref (worktree branch not yet
pushed). A `git fetch` failure must not exclude it from merge-base distance
detection. Resolve each candidate to `origin/<cand>` if present, else the local
ref, before skipping.

**Why** — Unconditional `git fetch origin "$CAND" || continue` drops every
unpushed candidate, leaving `BEST_DIST` at the sentinel and falling back to the
default branch — silent mis-basing of a stacked PR.

**Where** — wk-pr Step 1 base-detection loop, candidate-resolution line.
