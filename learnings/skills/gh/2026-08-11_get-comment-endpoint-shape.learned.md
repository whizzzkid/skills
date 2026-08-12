---
skill: wk-gh
date: 2026-08-11
type: correction
severity: medium
verified-against-source: yes
---

GitHub REST GET-single-review-comment endpoint omits the PR number segment

**What happened:** Fetching a single PR review comment by ID via
`repos/{owner}/{repo}/pulls/{pr}/comments/{id}` returned 404 for every valid ID.
The reply-POST endpoint (`/pulls/{pr}/comments/{id}/replies`) does include the PR
number, which made the GET path look correct by analogy.

**Root cause:** The GET-single-review-comment endpoint is
`repos/{owner}/{repo}/pulls/comments/{id}` — no PR number segment. The PR-numbered
path only exists for the POST-reply action. Confirmed by successful GET with the
correct path shape returning the expected comment payload.

**Suggested fix:** When the skill constructs a GET URL for a single review comment,
use `pulls/comments/{id}` (no PR number). Reserve `pulls/{pr}/comments/{id}/replies`
for POST-reply only. Add a note to `wk-gh` references distinguishing the two shapes.
