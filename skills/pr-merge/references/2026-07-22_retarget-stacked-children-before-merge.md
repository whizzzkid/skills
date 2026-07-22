---
class: principle
---

**Rule:** Before merging a PR with `--delete-branch`, detect any open PR whose
base is this PR's head branch and retarget each onto this PR's base FIRST, then
merge. Re-query and confirm every child's `baseRefName` equals the new base
before running the merge command.

**Why:** GitHub's automatic base-change on parent merge races with the branch
deletion and does not complete first — deleting the head branch can close/orphan
the stacked child before its base is moved, losing the child PR.

**Where:** wk-pr-merge Step 6 (Merge the PR), as a pre-merge HARD RULE ahead of
the `gh pr merge` command. Detection: `gh pr list --base {head} --state open`;
retarget: `gh pr edit {child} --base {base}`.
