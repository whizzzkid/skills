---
class: principle
---

**Rule:** Immediately before creating or recreating a pending review, compare the live pull-request head with the
investigated SHA. Revalidate the delta, findings, and anchors after drift; pin the payload with that SHA.

**Why:** Without an explicit `commit_id`, the review endpoint defaults to the latest pull-request commit. A push
between investigation and POST can therefore attach stale evidence to a newer target without an API error.

**Where:** [`wk-pr-review`](../README.md) Phase 5, "Recheck the reviewed head."
