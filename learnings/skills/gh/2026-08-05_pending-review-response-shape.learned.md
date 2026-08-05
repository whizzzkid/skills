---
skill: wk-gh
date: 2026-08-05
type: surprise
severity: medium
verified-against-source: yes
---

Verify pending-review comments through the review-specific endpoint.

**What happened:** A successful pending-review creation returned a review object without an embedded
comments collection, causing a client-side projection to fail after the write had succeeded.

**Root cause:** The create-review response does not guarantee expanded inline comments; a follow-up
read of the returned review ID exposed the staged comments and their anchors.

**Suggested fix:** Project only the review ID, state, and commit from the creation response, then GET
the review-specific comments endpoint before deciding whether the write succeeded or retrying it.
