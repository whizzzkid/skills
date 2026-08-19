---
skill: wk-pr-resolve
date: 2026-08-19
type: gap
severity: low
verified-against-source: yes
---

Posting a threaded reply to a review comment via the REST replies subresource requires the pull-request number as an explicit path segment; omitting it 404s with no hint about the missing segment.

**What happened:** A reply POST used `repos/{owner}/{repo}/pulls/comments/{id}/replies` (no PR number) and got a generic 404. The correct path is `repos/{owner}/{repo}/pulls/{pull_number}/comments/{id}/replies`.

**Root cause:** The skill's reply-posting guidance did not spell out the full path shape, so the PR-number segment was dropped when composing the endpoint from memory.

**Suggested fix:** Have the skill's reply-posting command block always show the full literal path with `{pull_number}` inline, so it can't be composed without that segment.
