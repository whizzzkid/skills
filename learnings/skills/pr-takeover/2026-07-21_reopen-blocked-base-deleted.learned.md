---
skill: wk-pr-takeover
date: 2026-07-21
type: gap
severity: medium
---

A PR whose base branch was merged-and-deleted auto-closes and cannot be reopened or retargeted.

**What happened:** A stacked PR's base branch was squash-merged into the default branch and deleted, which auto-closed the PR. `gh pr edit --base <default>` returned `GraphQL: Cannot change the base branch of a closed pull request`, and `gh pr reopen` returned `Could not open the pull request` (base ref gone).

**Root cause:** GitHub forbids both reopening and base changes on a closed PR when the original base ref no longer exists. There is no in-place revive path.

**Suggested fix:** On revive, detect the merged/deleted base first (`gh pr view --json state,baseRefName`; `git ls-remote --heads origin <base>` empty = gone). Recovery is `git rebase --onto origin/<default> <last-base-commit> HEAD` to re-parent only the PR's own commits, force-push, then open a NEW PR to the default branch that supersedes the closed one (cross-link both ways with a lifecycle comment). Do not attempt reopen/retarget.
