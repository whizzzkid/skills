---
class: principle
skill: wk-adversarial-review
date: 2026-06-23
---

**Rule**

After any change that wires a `context.Context`/`parentCtx` parameter into a
function, grep its error-handling block for **both** `context.Canceled` and
`context.DeadlineExceeded`. Both must be handled when the function is cancellable
from outside; asymmetric coverage versus a sibling function is a signal.

**Why**

Propagating a cancellable context without a `Canceled` case sends a
caller-cancel (SIGINT) down the generic error handler, emitting a misleading
"CLI failed" — the exact cancellation path the change was written to support.

**Where**

Merged into sweep 2.52 (extended catalog) — broadened from "verify Canceled is
reachable" to "both context error cases handled, matching the sibling."
