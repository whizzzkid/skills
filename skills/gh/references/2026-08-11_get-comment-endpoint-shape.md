---
class: one-off
date: 2026-08-11
skill: wk-gh
---

# GET-single-review-comment endpoint omits PR number

- **Scenario:** Fetching a single PR review comment by ID via
  `repos/{owner}/{repo}/pulls/{pr}/comments/{id}` returned 404.
- **Symptom:** Every valid comment ID 404d; the reply-POST endpoint
  (`/pulls/{pr}/comments/{id}/replies`) does include the PR number, making the
  GET path look correct by analogy.
- **Fix:** GET-single-review-comment is `repos/{owner}/{repo}/pulls/comments/{id}`
  (no PR number segment). Reserve the PR-numbered path for POST-reply only.
- **Why not promoted:** Step 3 inline-reply guidance already covers REST vs GraphQL
  ID distinctions. This is a narrow endpoint-shape correction. Body at ceiling.
