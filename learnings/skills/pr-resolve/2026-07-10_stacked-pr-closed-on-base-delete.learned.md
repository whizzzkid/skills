---
skill: wk-pr-resolve
date: 2026-07-10
type: gap
severity: high
---

A stacked PR based on another PR's branch is auto-CLOSED (not retargeted) when the parent squash-merges with delete-branch-on-merge.

**What happened:** PR-child had its base set to PR-parent's head branch. When
PR-parent squash-merged, the repo (squash-only, `delete_branch_on_merge: true`)
deleted the parent branch; GitHub's timeline showed `base_ref_deleted` → `closed`
with NO `automatic_base_change_succeeded` event. The child PR closed. Reopening
failed (`Could not open the pull request`) because its base branch no longer
existed, and the base could not be changed while closed
(`Cannot change the base branch of a closed pull request`).

**Root cause:** GitHub's auto-retarget of dependent PRs is best-effort and does
not reliably fire for stacked PRs, especially under squash-only merges plus
auto-delete-on-merge. There is no repo toggle to force "retarget instead of
close." Losing the base branch closes the PR.

**Recovery sequence (order matters):** (1) recreate the deleted base branch at
the merge target's current tip via `POST /repos/{o}/{r}/git/refs`
(`ref=refs/heads/<deleted-base>`, `sha=<target-branch-sha>`); (2) `gh pr reopen`;
(3) retarget base to the real target; (4) delete the temporary branch. The head
branch must still exist for any of this to work.

**Suggested fix:** In Step 2 (sync), when the PR is CLOSED and its base branch is
absent, detect the stacked-PR-closed-on-base-delete case and run the recovery
sequence before triaging. Prevention guidance for the PR-authoring skill: base
each stacked PR directly on the trunk, or retarget a child to the trunk BEFORE
merging its parent, whenever the parent branch will be auto-deleted.
