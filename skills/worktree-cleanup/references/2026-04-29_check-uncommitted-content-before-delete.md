---
class: principle
date: 2026-04-29
severity: medium
---

- **Rule:** Run `git status --short` and `git stash list` inside each merged worktree before deleting; surface non-disposable content to the user.
- **Why:** Merged status only covers committed work — staged, untracked-non-disposable, or stashed content can be unique to the worktree and is unrecoverable after `git wtr`.
- **Where:** Step 4 — "Pre-delete content scan" bullet at the start of the per-branch loop.
