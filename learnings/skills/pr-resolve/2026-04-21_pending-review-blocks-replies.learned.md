---
skill: wk:pr-resolve
date: 2026-04-21
type: gap
severity: medium
---

A pending (draft) self-review on the same PR blocks reply-comment posting with HTTP 422: `user_id can only have one pending review per pull request`.

**What happened:** Had a pending self-review from an earlier session. When `wk:pr-resolve` tried to post replies to reviewer comments via `/pulls/{n}/comments/{id}/replies`, GitHub rejected every reply with 422 — each reply is attached to an implicit review, and only one pending review per user is allowed. Resolved by submitting the pending review first (POST `/reviews/{id}/events` with event=COMMENT), after which replies posted fine.

**Root cause:** The `wk:pr-resolve` skill doesn't pre-check whether the current user has a pending (PENDING state) review on the PR before attempting to post replies. Step 8 assumes the reply endpoint is always available.

**Suggested fix:** In Step 3 or Step 8 of `wk:pr-resolve/SKILL.md`, add a pre-flight check:

```bash
# Check for own pending reviews that would block new replies
gh api repos/{owner}/{repo}/pulls/{number}/reviews --jq \
  '.[] | select(.state == "PENDING" and .user.login == "<current-user>") | .id'
```

If a pending review exists, prompt the user: "You have a pending self-review on this PR. Posting replies requires submitting or dismissing it first. Submit as COMMENT, or abort?" Then either submit via `POST /reviews/{id}/events` with `event=COMMENT` or abort the resolve flow.
