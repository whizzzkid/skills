---
skill: wk-self-review
date: 2026-08-27
type: gap
severity: medium
verified-against-source: yes
---

GitHub allows only one pending review per user per PR — a stale pending review blocks staging a new one with HTTP 422.

**What happened:** Staging a fresh pending self-review after new commits failed with `422 "user_id can only have one pending review per pull request"`. A pending review from an earlier round was still attached to the PR. The fix was `DELETE /pulls/{n}/reviews/{id}` on the stale pending review, then re-POST.

**Root cause:** The skill's "Updating an Existing Self-Review" section covers delete-and-restage on HEAD drift, but the create path (Step 4) never checks for an existing pending review before POSTing — so a leftover draft from any earlier round (or another flow) hard-blocks the POST.

**Suggested fix:** In Step 4, before the POST, query `GET /pulls/{n}/reviews` for a self-authored `state == "PENDING"` review; if found, preserve its comment bodies, DELETE it, and fold its still-valid comments into the new payload. Treat the 422 message as the recovery trigger, not a retry candidate.
