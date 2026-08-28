---
class: principle
---

**Rule** — Before POSTing a new pending review, query for a self-authored
`state == "PENDING"` review on the PR. If found, preserve its comment bodies,
DELETE it, fold still-valid comments into the new payload, then POST. Treat
HTTP 422 `"user_id can only have one pending review per pull request"` as a
recovery trigger, not a retry candidate.

**Why** — GitHub allows only one pending review per user per PR. The create
path (Step 4) went straight to POST without checking, so a leftover pending
review from an earlier round (or another flow) hard-blocked the POST with 422.

**Where** — `SKILL.md` → Step 4 pre-POST pending-review check bullet.
