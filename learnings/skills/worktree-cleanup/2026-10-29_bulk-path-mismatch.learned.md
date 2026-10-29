---
skill: wk-worktree-cleanup
date: 2026-10-29
type: gap
severity: medium
verified-against-source: n/a
---

Bulk cleanup of 100+ worktrees: alias assumes dir == branch, and per-worktree retro does not scale

**What happened:** Many worktree directories do not match their branch names (or branches contain slashes, or the
checkout is a detached HEAD), so `git wtr {branch}` would target a non-existent path. Separately, Step 4 requires a
retro per merged own-authored worktree; with ~40 of them the skill gives no batch or opt-out path, forcing an
interactive decision.

**Root cause:** Step 5 builds `worktrees/{branch}` from the branch name instead of using the path parsed in Step 1.
Step 4 assumes a handful of worktrees.

**Suggested fix:** Parse path+branch pairs from `git worktree list --porcelain`; remove with
`git worktree remove <path>` then `git branch -D <branch>`. Add a bulk rule: above N merged own worktrees, ask once
whether to batch the retro (single run over a path list) or skip it explicitly. Treat a copied local-config file as
disposable. Skip detached-HEAD entries explicitly.
