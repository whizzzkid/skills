---
class: principle
skill: wk-worktree-cleanup
date: 2026-05-29
---

# Current-worktree cleanup mode (`--current`)

- **Rule:** Support cleaning the worktree the agent is inside via `--current`;
  resolve main worktree (`dirname $(git rev-parse --git-common-dir)`), chdir to
  it, then `git worktree remove` the former current worktree.
- **Why:** `git worktree remove` refuses to remove the current working
  directory; the default sibling-scan mode assumed it always runs from main, so
  post-merge "clean up this worktree" had no path.
- **Where:** "Mode: clean the current worktree (`--current`)" section.
- **Guards:** Skip when already at main worktree (never remove repo root);
  require the branch be merged; reuse Step 3 merge-check + Step 4 retro guard.
