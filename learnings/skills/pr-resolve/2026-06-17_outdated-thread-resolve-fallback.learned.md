---
skill: wk-pr-resolve
date: 2026-06-17
type: gap
severity: medium
---

When a bot inline-comment thread goes fully outdated (line: None), all REST reply/resolve operations 404 — fall back to GraphQL resolveReviewThread + a summary conversation comment.

**What happened:** After multiple pushes that refactored the lines a bot had commented on, the bot's review thread became outdated (`line: null` in GraphQL `reviewThreads`). Every REST operation against the thread's `databaseId` returned 404: reply POST, resolve PATCH, even the read GET. The only working path was GraphQL `resolveReviewThread` mutation using the stable thread node ID (`PRRT_…`), plus posting a top-level conversation comment summarizing all the applied fixes as a substitute for the inline replies.

**Root cause:** The skill documents the REST-to-GraphQL fallback for reading comment bodies, but not for the reply-and-resolve step when threads are fully outdated. Once `line` is `null`, the REST comment ID is invalidated for all operations.

**Suggested fix:** In Step 8, before attempting a REST inline reply, check the GraphQL thread's `line` field. If `null` (outdated), skip the REST reply attempt and go directly to: (1) GraphQL `resolveReviewThread` using the node ID to close the thread, and (2) a single top-level `gh pr comment` summarizing all fixes applied to that set of outdated threads. Document this as the canonical fallback path in the skill's thread-resolution section.
