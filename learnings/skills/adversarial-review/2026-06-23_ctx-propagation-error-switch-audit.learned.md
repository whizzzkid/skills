---
skill: wk-adversarial-review
date: 2026-06-23
type: gap
severity: medium
---

When adding parentCtx propagation to a function, audit the error switch for all context error types.

**What happened:** A function was refactored to accept `parentCtx context.Context` instead of hardcoding nil. The error-handling branch checked `context.DeadlineExceeded` but not `context.Canceled`. Propagating a cancellable context without handling cancellation means a caller-cancelled (SIGINT) invocation falls through to the generic error handler and emits a misleading "CLI failed" message — the exact cancellation path the change was written to support.

**Root cause:** The sweep checked that the context was wired through (correct) but did not verify that all context-derived error cases in the error switch were also handled. The sibling function handled both Canceled and DeadlineExceeded; the new function only handled DeadlineExceeded.

**Suggested fix:** Add a sweep step: after any change that introduces or wires a `context.Context` parameter, grep the function's error-handling block for `context.Canceled` and `context.DeadlineExceeded`. Both must appear when the function can be cancelled from outside. Compare against the sibling function if one exists — asymmetric error-switch coverage is a signal.
