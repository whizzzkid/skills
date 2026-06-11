---
skill: wk-commit
date: 2026-06-11
type: gap
severity: low
---

A pre-staged change (e.g. a prior `git mv`) sits in the index and is swept into
the next `git commit`, merging it into an unrelated logical group.

**What happened:** Renames staged via `git mv` were committed as part of an
earlier hook-infra commit instead of their own chore commit, because
`git commit` commits the whole index — not only the paths named in the
preceding `git add`.

**Root cause:** Grouped-commit guidance assumes `git add <paths>` defines the
commit contents, but anything already staged (git mv, an earlier add) rides
along silently.

**Suggested fix:** Before each grouped commit, verify the staged set with
`git diff --cached --name-only` and confirm it matches exactly the intended
group; unstage strays with `git restore --staged <paths>` (or `git stash`
the unrelated change) before committing. Treat `git mv` as already-staged.
