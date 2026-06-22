---
skill: wk-adversarial-review
date: 2026-06-22
type: correction
severity: high
---

Context propagation dropped when extracting a subprocess helper

**What happened:** A subprocess-setup helper was extracted from a function that accepted a `parentCtx context.Context` param. The helper used `context.Background()` internally instead of the parent context, silently dropping caller-supplied cancellation (e.g. SIGINT). The error switch inside the caller had a `context.Canceled` case that became unreachable — callers were passing a real cancellation context, but the subprocess never received it.

**Root cause:** The extraction moved the `context.WithTimeout` call into the helper body and defaulted to `context.Background()`. The original function's parent-context propagation was not carried forward. The refactor looked complete (same timeout, same args), but the nil→Background guard and the parent-context wrapping were both dropped without a direct test exercising the Canceled path.

**Suggested fix:** In adversarial review, add a sweep for this pattern: grep for `context.Background()` calls inside helpers that are invoked by functions accepting a `context.Context` parameter. Any such call is a candidate dropped propagation. Also check that every error-switch `case ctx.Err() == context.Canceled` (or equivalent) is reachable — an unreachable case is a signal the context was not plumbed through. The fix is to add `parentCtx context.Context` as the first param to the helper with a `nil → context.Background()` guard, matching the pattern the original function used.
