---
class: principle
skill: wk-gh
date: 2026-11-20
---

# Detect a pending review before any thread reply, REST included

- **Rule:** Before any review-thread reply, REST or GraphQL, query `GET /pulls/{n}/reviews` for the acting user's
  `state == PENDING` review. When one exists, follow the existing Step 3 route: ask the user to submit or discard it,
  or to approve adding the replies to it.
- **Why:** With a self-review staged but not submitted, `POST /pulls/{n}/comments/{id}/replies` returned 422 "user_id
  can only have one pending review per pull request": a reply creates a review comment, and a user can hold only one
  pending review per PR. The pending-review check was worded for GraphQL replies only, so the REST path hit the 422
  instead of detecting the draft up front.
- **Where:** `SKILL.md` → Step 3. Source: gh learning and the 2026-11-21 session-1 retrospect.
