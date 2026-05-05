---
skill: wk-retro
date: 2026-04-22
type: gap
severity: medium
---

Step 2 merge creates divergent history when remote PR branch already has its own merge commit.

**What happened:** `git merge origin/main` succeeded locally, but `git push` was rejected (non-fast-forward) because GitHub's "Update branch" button had already merged main into the remote PR branch via a separate merge commit. Rebasing local commits onto `origin/wish/5068` resolved it.

**Root cause:** `wk-pr-resolve` Step 2 unconditionally merges the base branch locally without checking if the remote PR branch already has a merge commit ahead of the local branch. The two merge commits diverge the histories.

**Suggested fix:** After `git merge origin/{base_branch}`, check `git log --oneline origin/{head_branch}..HEAD` and if the remote is ahead, run `git rebase origin/{head_branch}` to reconcile before pushing.
