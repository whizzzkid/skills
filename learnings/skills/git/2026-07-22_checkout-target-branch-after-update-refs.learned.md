---
skill: wk-git
date: 2026-07-22
type: correction
severity: high
---

After a `--update-refs` rebase, verify the checked-out branch before committing.

**What happened:** A `git rebase --onto <newbase> <oldbase> <branch> --update-refs`
rebuilt a multi-branch stack and advanced the descendant branch pointers. The
agent then wrote and committed the next feature's work without running
`git checkout` into that feature's branch — the commit landed on the wrong
(parent) branch of the stack. Caught immediately via `git status`, fixed with
`git branch -f`/`git checkout` before any push, so no data loss.

**Root cause:** `--update-refs` moves branch *pointers* but leaves HEAD on
whatever branch was checked out for the rebase. The agent assumed the rebase left
it on the topmost branch; it did not.

**Suggested fix:** Immediately after any `--update-refs` rebase (or any rebase
that rewrites a stack), run `git branch --show-current` / `git status` and
explicitly `git checkout` the intended branch before the next Write or commit.
Never assume a rebase leaves HEAD on the branch you intend to work on next.
