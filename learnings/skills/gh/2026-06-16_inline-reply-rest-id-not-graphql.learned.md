---
skill: wk-gh
date: 2026-06-16
type: correction
severity: medium
---

Use numeric REST IDs (not GraphQL node IDs) for `in_reply_to` when posting inline PR review comment replies.

**What happened:** Attempted to post a reply to a PR inline review comment using a GraphQL node ID (e.g., `PRRC_kwDO...`) as the `in_reply_to` value in `POST repos/{owner}/{repo}/pulls/{n}/comments`. The API returned 404.

**Root cause:** The `in_reply_to` field on the pull request review comments endpoint expects the integer REST ID of the comment, not the GraphQL node ID. GraphQL node IDs (`PRRC_...`) are a different identifier space and are not accepted by this REST endpoint parameter.

**Suggested fix:** When posting inline comment replies, fetch the numeric `id` field from `GET repos/{owner}/{repo}/pulls/{n}/comments` or from the `comments.nodes[].databaseId` field in a GraphQL reviewThreads query. Pass that integer to `in_reply_to`, not the `node_id` / GraphQL cursor.
