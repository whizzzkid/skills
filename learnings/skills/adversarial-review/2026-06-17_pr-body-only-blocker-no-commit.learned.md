---
skill: wk-adversarial-review
date: 2026-06-17
type: pattern
severity: low
---

When the only adversarial-review blocker is PR body drift, fix it with gh pr edit — no commit needed

**What happened:** Sweep 2.8 flagged a blocker because the PR body enumerated stale
reason symbols. All code was correct; the only gap was metadata in the GitHub PR
description. The skill's "blocked → fix via wk-commit → re-invoke" loop implies a code
commit, but this case has no code to change.

**Root cause:** The fix loop in Step 7 says "Caller fixes each blocker via wk-commit
(one atomic conventional commit per fix)." This wording implies a git commit is always
needed, but PR body is GitHub API state, not a committed file. Committing a no-op to
satisfy the loop would pollute history.

**Suggested fix:** Add a carve-out to Step 7: when the only blocker is PR body drift
(sweep 2.10 or 2.8 PR body check), fix it via `gh pr edit` with no new commit, then
re-run the adversarial review against the same HEAD SHA. The `.cleared-{HEAD_SHA}.json`
record is still valid — the code hasn't changed, only the metadata.
