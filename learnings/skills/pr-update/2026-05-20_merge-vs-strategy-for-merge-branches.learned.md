---
skill: wk-pr-update
date: 2026-05-20
type: correction
severity: medium
---

Skill invoked patch-replay strategy (≥5 commits) when a plain `git merge` was the right tool, because the branch already had a prior merge commit from the same base.

**What happened:** Branch had 13 commits ahead (≥5 threshold → patch-replay) and 2 behind. But the branch already contained a merge commit from main made earlier that session. The 2 new main commits were unrelated to the branch's work. Correct action: `git merge origin/main`. Instead, the skill triggered the patch-replay discussion, which would have squashed 13 reviewed commits into 1.

**Root cause:** The commit-count heuristic fires on raw `$AHEAD` without considering whether the branch already integrates the base via a merge commit. A branch with a prior merge commit is semantically "already up to date" — only the delta since that merge needs integrating, regardless of total commit count.

**Suggested fix:** Before applying the strategy heuristic, check whether HEAD already contains a merge commit from the base branch. If it does, compute `$AHEAD` only against the most recent such merge, not the full divergence. When the delta since the last merge is small (e.g., ≤5 new base commits that are unrelated), prefer `git merge` over patch-replay.
