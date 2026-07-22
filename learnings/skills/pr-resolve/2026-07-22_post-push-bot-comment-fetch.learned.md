---
skill: wk-pr-resolve
date: 2026-07-22
type: gap
severity: medium
---

Step 3 should re-fetch full bot comment bodies post-push

**What happened:** After pushing merge/fix commits, a review bot posted new inline review findings. The initial Step 3 fetch grabbed unresolved thread IDs but not full comment bodies; a user redirect was needed to surface the findings for triage.

**Root cause:** Step 3's comment-fetch logic runs once per merge attempt, before any push. A push that triggers CI and new bot findings has no automatic follow-up fetch of the new findings' full bodies — only a manual re-run of Step 3 or a user redirect surfaces them.

**Suggested fix:** After each `git push` in Step 8, append a re-fetch of bot inline comment bodies via the REST API to surface any new findings from post-push CI runs (review-bot runs) before reporting the summary. This makes new findings discoverable without requiring a second Step 3 invocation.
