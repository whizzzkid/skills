---
class: principle
---

# Reconcile superseded check runs

**Rule:** Before failing a cancelled current-HEAD check, find a newer run of the same workflow and HEAD. Wait when
that replacement is live; otherwise use the newest matching run's terminal conclusion.

**Why:** Workflow concurrency can cancel one run while its replacement is queued. Treating the older cancellation
as final blocks a merge whose authoritative run has not finished.

**Where:** `wk-gh` status-rollup handling and every merge workflow that consumes it.
