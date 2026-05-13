---
skill: wk-worktree-cleanup
date: 2026-05-13
type: gap
severity: low
---

`git wtr` fails on worktrees with untracked `.review-playground/` directories left by `wk-pr-review`.

**What happened:** Two merged worktrees had untracked `.review-playground/` directories. `git worktree remove` refused to delete them without `--force`, blocking cleanup.

**Root cause:** The skill's "disposable paths" list in Step 4 doesn't mention `.review-playground/` — only lock files, OS metadata, and `.gitignore`-matched content are listed. `git clean -fd` was not run before `git wtr`.

**Suggested fix:** Add `.review-playground/` to the disposable-paths list in Step 4. Before calling `git wtr`, run `git clean -fd` (scoped to known disposable patterns) so `git worktree remove` succeeds without `--force`.
