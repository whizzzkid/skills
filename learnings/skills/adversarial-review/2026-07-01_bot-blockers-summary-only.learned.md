---
skill: wk-adversarial-review
date: 2026-07-01
type: gap
severity: medium
---

A bot reviewer's new blocking findings can exist only in its summary comment body, with no corresponding inline review thread — checking inline threads alone misses them.

**What happened:** After a fix landed and CI passed, the calling skill declared the PR mergeable based on green CI and resolved inline threads. In fact the bot's re-review had posted two new Major findings in its top-level summary comment (issues/comments), not as inline `reviewThreads` entries, and GitHub's `mergeStateStatus` was `BLOCKED`/`REVIEW_REQUIRED`. The false "ready" claim was caught only because the user pushed back.

**Root cause:** The gate's re-review check treated "no new inline threads" as equivalent to "no new findings." A bot can emit blocker-severity findings purely in prose inside its issue-comment summary, especially when the finding isn't tied to a diff line the bot's tool anchored a thread to.

**Suggested fix:** After any bot re-review, fetch the PR's `mergeStateStatus`/`reviewDecision` directly (source of truth) and also grep the latest bot issue-comment/review body for severity markers (e.g. "Major", "blocker") before declaring ready — never infer mergeability from CI status or inline-thread count alone.
