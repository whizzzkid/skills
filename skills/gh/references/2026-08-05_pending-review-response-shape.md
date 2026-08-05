---
class: principle
---

# Verify pending-review comments through their endpoint

**Rule** — Project only review ID, state, and commit from the create response. GET the review-specific comments
endpoint and verify staged anchors before deciding success or retry.

**Why** — A successful create-review response need not embed its comments collection.

**Where** — Step 3 pending-review write verification.
