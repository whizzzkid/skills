---
skill: wk-pr-resolve
date: 2026-06-29
type: correction
severity: medium
---

Detect and surface a pending self-review before attempting inline replies, not mid-flow.

**What happened:** A pending self-review blocked inline reply posting with an HTTP 422 mid-flow. The skill already has a Step 3 pre-check for `$PENDING_REVIEW_ID`, but it did not fire early enough — the 422 only surfaced at reply time in Step 8.

**Root cause:** Re-violation of an existing rule. The Step 3 pre-check was phrased as an ordinary bold lead-in and was skipped; the cost (a mid-flow 422) was paid at reply time instead of being caught up front.

**Suggested fix:** Escalate the Step 3 pre-check one notch to an `**Important:**` rule that names the failure mode explicitly — pre-check pending self-reviews at Step 3, never discover them at reply time. Submit/abort the pending review before any reply.
