---
class: one-off
---

# Re-read a review's state on a submit 422

**Rule**

- A 422 `"Could not comment pull request review."` from `/reviews/{id}/events` → re-GET the review and check
  `state` / `submitted_at` before retrying or changing the payload. Not `PENDING` → report and stop; never resubmit.

**Why**

- The user submitted the review in the browser the agent had just opened, between the agent's `PENDING` check and
  its submit call. Two submits with different payloads both returned the same 422, whose text does not say
  "already submitted".

**Classification**

- One-off: narrow API-response mechanics, filed in the linked pending-review mechanics reference rather than
  `SKILL.md`.

**Where**

`skills/gh/references/pending-review-mechanics.md` → "Submit 422" section.
