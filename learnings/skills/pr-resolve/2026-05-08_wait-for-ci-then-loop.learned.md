---
skill: wk-pr-resolve
date: 2026-05-08
type: gap
severity: medium
---

After pushing, skill should wait for CI to pass before declaring resolution complete.

**What happened:** Skill finished at Step 10 immediately after push + reply posting, without checking whether CI passed on the new commits. Any new bot review findings triggered by the push (e.g., {repo} re-running, Copilot re-reviewing) were left unaddressed until the next manual invocation.

**Root cause:** Step 8 only checks for merge conflicts (Step 9) and then summarizes. There is no CI polling step and no loop-back to Step 3 to re-fetch comments after CI completes.

**Suggested fix:** After Step 9 (merge conflict check), add a Step 9.5: poll CI status via `wk-buildkite` until the build reaches a terminal state (passed/failed/canceled). If passed, re-run Step 3 to fetch any new unresolved comments triggered by the push. If new comments exist, run Steps 4–8 again. Exit the loop only when CI passes AND no new unresolved reviewer/bot comments remain. If CI fails, surface the failure and exit — CI fixes take priority over remaining review comments.
