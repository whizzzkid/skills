---
class: principle
---

**Rule** — When a diff adds/edits a `rescue`/`catch`/`except` block that calls a typed API (sorbet sig, TypeScript, mypy, typed Go params), verify every argument type against the callee signature — especially an identifier/class/module param a plain String could be wrongly passed for. The error path must satisfy the same typed-argument contract as the happy path.

**Why** — A boot-time guard's `rescue` reported to an error-tracking API whose `calling_class` param is runtime-type-enforced (Module/class), but a plain String was passed. On the first real error the handler would raise `TypeError` at the moment it was supposed to degrade — turning a soft-fail into the hard crash it was written to avoid. The happy-path contract sweep (2.7) missed it because a handler reads as defensive, so its own call sites escaped scrutiny.

**Where** — `wk-adversarial-review` sweep 2.62 (extended catalog); listed in the inline extended-sweep ID pointer.
