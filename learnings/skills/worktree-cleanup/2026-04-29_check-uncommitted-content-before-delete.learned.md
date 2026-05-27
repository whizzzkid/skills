---
skill: wk-worktree-cleanup
date: 2026-04-29
type: gap
severity: medium
---

Check for uncommitted content in merged worktrees before deleting — merged branches can still contain untracked or staged artifacts not present in main.

**What happened:** Several merged worktrees contained uncommitted content (a blog post draft, a PR review doc) not present in main. The skill had no step to surface this before deciding to delete.

**Root cause:** Skill assumes a merged PR means the worktree's content is all in main. Uncommitted content (stashed work, drafts, docs added but never committed) is invisible to the merge check.

**Suggested fix:** Before deleting any worktree, run `git -C <path> status --short` and `git -C <path> stash list`. Surface any uncommitted or stashed content to the user before proceeding with deletion.
