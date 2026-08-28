---
skill: wk-pr-update
date: 2026-08-28
type: gap
severity: medium
verified-against-source: yes
---

Worktree's checked-out branch may not be the PR the user wants updated — verify against open/DIRTY PRs first.

**What happened:** A "resolve merge conflicts, make this mergeable" request ran in a worktree whose directory was named after a parent branch but had an abandoned stacked child branch checked out (its PR closed as "no longer needed"). The child had no open PR; the only open, conflicted PR was the parent's. Stage 1's base detection via `gh pr view` on the current branch would have targeted a closed PR.

**Root cause:** Stage 0/1 assume the checked-out branch is the integration target. No step cross-checks the current branch's PR state (open vs closed) or scans for the actual DIRTY PR when the branch's own PR is closed or missing.

**Suggested fix:** In Stage 1, after resolving the PR for the current branch, check `state`. If closed/merged or absent, look for an open PR whose head is the worktree's namesake branch (or the branch's stack parent) with `mergeStateStatus: DIRTY`, and switch the worktree to that branch (after confirming the closed PR's work was explicitly abandoned) before choosing a strategy.
