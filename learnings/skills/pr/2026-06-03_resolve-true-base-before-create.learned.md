---
skill: wk-pr
date: 2026-06-03
type: correction
severity: high
---

Always resolve the true base branch before creating a PR.

**What happened:** PR was created targeting `main` (default branch) instead of an in-flight branch (`v5`) that the feature branch was actually forked from. The diff against `main` contained 8 commits and 21 changed files instead of the 2 commits and 7 files that were actually new.

**Root cause:** The wk-pr skill includes a base-detection algorithm (merge-base distance against all open PR heads), but it was not executed before `gh pr create`. The default branch was assumed without running the detection step.

**Suggested fix:** Make the merge-base distance detection non-optional in Step 1 — run it unconditionally before measuring scope or calling `gh pr create`. The base must be the closest ancestor among all open PR head refs and the default branch. When the resolved base differs from the default, surface it to the user before proceeding. Never skip this check even for "obviously simple" branches.
