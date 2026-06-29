---
class: principle
---

**Rule:** Run the pending-self-review pre-check at Step 3, never discover a
pending review at reply time. A pending review blocks reply posting with HTTP
422; capture `$PENDING_REVIEW_ID` up front and submit/abort before any reply.

**Why:** Re-violation escalation. The Step 3 pre-check rule already existed but
re-fired mid-flow — the 422 surfaced only when posting replies in Step 8. The
rule failed to fire early, so it was escalated one notch from a plain bold
lead-in to an `**Important:**` rule that names the failure (discovering it at
reply time) explicitly.

**Where:** Step 3 (Fetch Unresolved Comments), pending-self-review pre-check.
Escalation: bold lead-in → `**Important:**`.
