---
skill: wk-pr-resolve
date: 2026-04-30
type: gap
severity: medium
---

Bot review replacement can happen mid-session, not just on the first fetch — re-fetch thread IDs after push but before reply-posting for any bot account ending in [bot].

**What happened:** {bot} replaced its review between the initial GraphQL fetch and the post-push reply phase. Three of eight POST /replies calls returned 404. Had to re-fetch current comment IDs and repost. The skill already documents 404 recovery for the post-push phase but frames it as a first-fetch problem, not a mid-session one.

**Root cause:** Step 3 fetches thread IDs once. Step 8's push triggers a new bot review, expiring the IDs. The Step 8 404-recovery path says to retry, but doesn't instruct proactive re-fetch for known-replacement bots.

**Suggested fix:** Add to Step 8 before "Post reply comments": "If any reviewer is a bot account (`[bot]` suffix), re-run the GraphQL `reviewThreads` query from Step 3 after the push and before posting replies. Bot reviews fire immediately on push; the pre-push IDs may be stale."
