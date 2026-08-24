---
skill: wk-pr-merge
date: 2026-08-24
type: gap
severity: medium
verified-against-source: yes
---

Bot resolves threads but posts COMMENTED not APPROVED — push empty commit to trigger re-evaluation

**What happened:** After resolving all bot review threads, the review bot's
latest review remained `COMMENTED` (not `APPROVED`), leaving `reviewDecision`
at `REVIEW_REQUIRED` and blocking auto-merge. The bot does not re-evaluate
resolved threads without a new push event.

**Root cause:** The merge skill assumes resolving threads triggers the bot to
re-approve. In practice, the bot only re-evaluates on a new push event — it
does not poll for thread resolution state changes.

**Suggested fix:** Add to Step 4 or Step 6: "If all bot threads are resolved
but `reviewDecision` remains `REVIEW_REQUIRED` and the bot's latest review is
`COMMENTED`, push an empty commit (`git commit --allow-empty`) to trigger a new
bot review cycle. Wait for the bot to post an `APPROVED` review before
proceeding."
