---
skill: wk-pr-resolve
date: 2026-06-25
type: pattern
severity: low
---

Bot inline thread REST reply 404s after bot replaces its review; fall back to a top-level PR comment.

**What happened:** Attempting `POST /pulls/comments/{id}/replies` for a bot-authored inline thread returned 404. The REST comment ID from `GET /pulls/{n}/comments` was stale — the bot had replaced its review, invalidating the `databaseId`.

**Root cause:** Bot reviewers repost entire reviews rather than editing; the new review creates new comment IDs. The previous REST ID no longer exists for any operation (read or write). The skill documents this for resolution (`resolveReviewThread`) but the reply path also 404s.

**Suggested fix:** When an inline-reply POST 404s on a bot thread, immediately fall back to `gh pr comment` (top-level) summarizing all bot-finding resolutions in one comment. Do not retry with a different REST ID — the thread is gone. Resolve the GraphQL thread node ID (stable) to close it. The skill already documents this fallback for the outdated-thread case; make it the explicit path for any bot-inline-reply 404.
