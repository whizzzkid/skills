---
skill: wk-pr
date: 2026-06-17
type: correction
severity: high
---

Stacked PR created with wrong base branch despite a closer candidate existing among open PR head refs.

**What happened:** Step 1's merge-base distance detection was not executed. Instead, `gh pr create` was called with `--base main` (the default branch) even though the current branch had branched from another in-flight branch that was closer by commit distance. The user had to manually correct the base branch on GitHub.

**Root cause:** The Step 1 merge-base algorithm exists in the skill instructions but was skipped in practice. The agent assumed the default branch was the correct base without running the candidate sweep over open PR head refs.

**Suggested fix:** Add an explicit enforcement gate before any `gh pr create` call: the `$BEST_BASE` variable must be set by running the merge-base distance loop — even when the PR "obviously" targets the default branch. If `$BEST_BASE != $DEFAULT_BRANCH`, surface the stacked-PR prompt (options A/B/C) before proceeding. Never pass `--base` to `gh pr create` until `$BEST_BASE` is confirmed by the algorithm.
