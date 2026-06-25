---
skill: wk-adversarial-review
date: 2026-06-25
type: gap
severity: high
---

New subprocess/LLM call sites must forward the app's cancellation context, not hardcode context.Background().

**What happened:** A new LLM dispatch function used `context.Background()` instead of the app `Context` struct's `GoCtx` field, breaking SIGINT/SIGTERM propagation to in-flight classifier calls.

**Root cause:** The sweep catalog has no rule targeting `context.Background()` literals in new call sites that have a live cancellation context available. The app wraps Go's `context.Context` in a domain struct; new callers don't obviously know the wrapper exists.

**Suggested fix:** Add sweep 2.X — on any new `context.Background()` literal in a function that receives a struct containing a `context.Context` field (or any type embedding one), flag as a blocker: "is there a live context available? prefer it over Background()." The nil-guard in the callee makes forwarding always safe.
