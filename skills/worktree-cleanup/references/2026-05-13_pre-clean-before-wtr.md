---
date: 2026-05-13
slug: pre-clean-before-wtr
---

- **Rule:** Run `git clean -fd` inside the worktree before `git wtr`, scoped to the worktree path, only after Step 4 confirmed every untracked path is disposable.
- **Why:** `git worktree remove` refuses to delete a worktree containing untracked files; falling back to `--force` would mask non-disposable work.
- **Where:** `Step 5 → Pre-clean disposable untracked content` in `wk-worktree-cleanup` SKILL.md.
