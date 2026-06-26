---
class: principle
---

**Rule:** Rename a `.learned.md` with plain `mv`, not `git mv`, then `git add` the new
path.

**Why:** A learning materialized this run (via `wk-learn` from a memory or retro) has
never been committed, so it is untracked. `git mv` requires a tracked source and aborts
with `fatal: not under version control`. Plain `mv` works for both tracked and untracked
files.

**Where:** Step 8 commit bullet — the `.learned.md` rename-staging line.
