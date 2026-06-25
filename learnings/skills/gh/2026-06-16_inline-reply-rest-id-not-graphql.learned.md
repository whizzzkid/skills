---
skill: wk-gh
date: 2026-06-16
type: correction
severity: medium
---

Use numeric REST IDs (not GraphQL node IDs) for `in_reply_to` when posting inline PR review comment replies.

**What happened:** Attempted to post a reply to a PR inline review comment using a GraphQL node ID (e.g., `PRRC_kwDO...`) as the `in_reply_to` value in `POST repos/{owner}/{repo}/pulls/{n}/comments`. The API returned 404.

**Root cause:** The `in_reply_to` field on the pull request review comments endpoint expects the integer REST ID of the comment, not the GraphQL node ID. GraphQL node IDs (`PRRC_...`) are a different identifier space and are not accepted by this REST endpoint parameter.

**Suggested fix:** Prefer the dedicated `/replies` subresource: `POST repos/{owner}/{repo}/pulls/{n}/comments/{comment_id}/replies` with only `--field body="..."`. This is simpler and avoids `in_reply_to` formatting issues entirely. If using the base endpoint instead, pass the integer comment ID via `--field in_reply_to=<int>` (not `-f`, which sends strings and causes 422).

## Additional evidence

Attempted `POST .../pulls/{n}/comments` with `-f in_reply_to=<int>` (string field) → 422 "is not a number". Correct: use the subresource `POST .../pulls/{n}/comments/{id}/replies --field body="..."` — avoids the field entirely.
