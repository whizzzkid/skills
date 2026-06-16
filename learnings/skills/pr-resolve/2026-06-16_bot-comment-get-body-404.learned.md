---
skill: wk-pr-resolve
date: 2026-06-16
type: surprise
severity: medium
---

REST GET for bot inline comment body returns 404 — use GraphQL reviewThreads to read it.

**What happened:** Attempted to fetch a bot's inline comment body via `GET /pulls/{n}/comments/{id}`. The request returned 404. Fell back to fetching the full body via GraphQL `reviewThreads` query, which succeeded using the stable thread node ID.

**Root cause:** After a bot replaces its review object, the REST `databaseId` for the original comment is invalidated. Even read (`GET`) requests to that comment ID return 404, not just write (reply/resolve) requests. The skill only documented POST-reply 404s, not GET-body 404s.

**Suggested fix:** When fetching a bot's inline comment body in Step 3 or Step 8, prefer GraphQL `reviewThreads` → `comments.nodes[0].body` over REST `GET /pulls/{n}/comments/{id}`. REST comment IDs for {bot}-authored reviews are unstable across pushes for all operations (read, reply, resolve).
