---
skill: wk-pr-resolve
date: 2026-05-20
type: correction
severity: medium
---

wk-pr-resolve delegated base integration to wk-pr-update when the right action was `git merge main`.

**What happened:** Branch was 2 commits behind main, but already had a recent merge commit from main. wk-pr-resolve's Step 2 unconditionally delegates to wk-pr-update, which triggered a patch-replay strategy discussion. The user had to intervene with "why didn't you just do `git merge main`?"

**Root cause:** The "delegate to wk-pr-update" rule in Step 2 fires unconditionally without a simple pre-check: if the branch already has a merge commit from the base and is only a few commits behind, `git merge origin/<base>` is the right call — no strategy computation needed.

**Suggested fix:** In Step 2, before invoking wk-pr-update, check whether HEAD contains a merge commit from the base branch and whether `$BEHIND` is small (e.g., ≤5). If both are true, run `git merge origin/$BASE` directly rather than delegating — only invoke wk-pr-update when the integration is non-trivial.
