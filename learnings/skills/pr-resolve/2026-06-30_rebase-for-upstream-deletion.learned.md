---
skill: wk-pr-resolve
date: 2026-06-30
type: correction
severity: high
---

Merge-into-branch does not resolve GitHub's test-merge conflict when upstream deleted a file our branch modified.

**What happened:** Merged `origin/main` into the feature branch and pushed. GitHub's `mergeable` status remained `CONFLICTING` because the three-way merge ancestor still contained the deleted file, so GitHub's own test-merge logic saw a conflict even though the local merge succeeded.

**Root cause:** GitHub computes mergeability independently using the common ancestor at the time the PR was opened. A merge commit on the branch tip does not change what GitHub sees as the conflict — it still reconciles from the original ancestor. Only rebasing the branch onto the current base gives GitHub a new ancestor that does not contain the deleted file.

**Suggested fix:** When `gh pr view --json mergeable` returns `CONFLICTING` after a merge-into-branch, pivot immediately to `git rebase --onto origin/$BASE $MERGE_BASE HEAD`. Do not attempt a second merge or manual conflict resolution — rebase is the correct tool when the conflict stems from an upstream deletion.
