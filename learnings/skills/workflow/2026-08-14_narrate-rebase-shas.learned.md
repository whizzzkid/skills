---
skill: wk-workflow
date: 2026-08-14
type: gap
severity: medium
verified-against-source: n/a
---

Narrate before/after SHAs when rebasing or pushing to a shared branch

**What happened:** After running `git pull --rebase` and pushing to a PR branch, {user} believed the push had been a force-push that discarded their changes. Investigation confirmed no work was lost, but the concern arose because the rebase/push sequence produced no visible evidence of what was preserved.

**Root cause:** The workflow skill does not instruct the agent to report SHAs before and after a rebase or non-trivial push. Without that audit trail, the user has no way to verify the operation was safe without inspecting `git log` themselves.

**Suggested fix:** Add a post-rebase/push narration step to `wk-workflow` Phase 2 or `wk-commit`: after any `git pull --rebase` or `git push` to a branch with existing remote commits, print the before-SHA, after-SHA, and a one-line summary of what changed (e.g., "rebased 1 local commit on top of 2 new remote commits, no conflicts").
