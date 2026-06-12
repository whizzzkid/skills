---
class: principle
date: 2026-06-12
skill: wk-pr-merge
---

- **Rule:** Always pass `--repo "$GITHUB_ORG/{repo}"` to `gh pr merge` — it
  forces API-only behavior and skips local branch manipulation.
- **Why:** `--delete-branch` runs a local base-branch checkout that fails in a
  git worktree where the base is checked out elsewhere; `--repo` is idempotent
  in both worktree and regular checkouts.
- **Where:** Step 6 Merge the PR — canonical squash command + worktree note.
