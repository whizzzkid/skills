---
class: principle
skill: wk-gh
date: 2026-06-16
---

**Rule:** When posting inline PR review comment replies, pass the integer REST
`id` to `in_reply_to` (or the `/pulls/{n}/comments/{id}/replies` path). Source it
from `GET /pulls/{n}/comments` or `databaseId` in a GraphQL reviewThreads query.

**Why:** The reply endpoints accept the REST integer ID space, not GraphQL node
IDs. Passing a GraphQL node ID (`PRRC_…`) returns 404 — a different identifier
space the REST parameter does not resolve.

**Where:** Step 3 — Canonical surface for GitHub writes (inline-reply surface).
