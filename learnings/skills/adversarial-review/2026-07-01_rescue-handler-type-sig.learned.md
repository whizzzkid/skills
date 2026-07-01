---
skill: wk-adversarial-review
date: 2026-07-01
type: gap
severity: high
---

Error-handling code added to prevent a crash can itself crash: a `rescue`/`catch` block that calls a typed observability API with the wrong argument type raises inside the handler and defeats its own purpose.

**What happened:** A boot-time guard wrapping third-party internal calls was given a `rescue` that reported to an error-tracking API. The `calling_class` parameter of that API is runtime-type-enforced (a sig requiring a Module/class), but a plain String was passed. On the first real error the handler would raise `TypeError` at the exact moment it was supposed to degrade gracefully — turning a soft-fail into the hard boot crash it was written to avoid. The general adversarial subagent caught it; no mechanical sweep row targeted "type-check the arguments of calls made *inside* a new rescue/catch block against their enforced signature."

**Root cause:** Sweeps checked the happy path's signatures (2.7 contract widening) but did not treat the error path itself as code that must satisfy typed-argument contracts. A rescue block reads as defensive, so its own call sites escape scrutiny.

**Suggested fix:** Add a sweep trigger: when a diff adds/edits a `rescue`/`catch`/`except` block that calls a typed API (sorbet sig, TypeScript, mypy, Go typed params), grep the callee's signature and verify every argument type — especially any identifier/class/module argument that a plain string could be mistakenly passed for. The error path must pass the same type contract as the happy path; a raise inside a handler is strictly worse than the error it handles.
