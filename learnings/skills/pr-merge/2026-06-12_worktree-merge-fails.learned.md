---
skill: wk-pr-merge
date: 2026-06-12
type: gap
severity: medium
---

`gh pr merge` fails inside a git worktree when the base branch is checked out in the parent worktree.

**What happened:** Running `gh pr merge NNN --squash --delete-branch` from inside a dedicated worktree emitted `fatal: 'main' is already used by worktree at '<path>'` because `gh` tried to manipulate the local branch checkout. The command succeeded only after adding `--repo $GITHUB_ORG/{repo}`, which bypasses local branch manipulation entirely.

**Root cause:** `gh pr merge` attempts a local `git checkout` of the base branch before/after the merge when `--delete-branch` is given. In a worktree where the base branch is already checked out elsewhere, this fails with a fatal worktree conflict. The `--repo` flag forces GitHub API-only behavior and avoids any local branch manipulation.

**Suggested fix:** Step 6 of wk-pr-merge should always use `gh pr merge {number} --squash --delete-branch --repo $GITHUB_ORG/{repo}` as the canonical form; this is idempotent in both worktree and regular checkout environments. Detect worktree context early (via `git worktree list | wc -l > 1`) and log a note when the worktree-safe form is selected.
