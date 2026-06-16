---
skill: wk-adversarial-review
date: 2026-06-16
type: pattern
severity: low
---

Collapsing a single-field options struct to a plain parameter merges two semantically distinct zero-value states into one empty-string sentinel.

**What happened:** A function accepted an options struct with one field (`coreCheckSHA string`). The struct was removed and replaced with a plain `string` parameter. Both callers now pass `""` — but one passes it to mean "this is intentional local mode" and the other passes it because a required env var was unset (with a warning logged). The prior struct made both states look identical at the call site, but it also had explicit named-field syntax that gave future readers a hint. With a bare `""`, the two cases are invisible.

**Root cause:** When removing a wrapper struct that has only one field, the "premature abstraction" critique is valid structurally, but it's worth checking whether the zero-value of the underlying type is already overloaded before collapsing.

**Suggested fix:** Add to the single-field-struct removal check: "does the zero-value of the field (`""`, `0`, `false`, `nil`) appear in two or more callers for different semantic reasons?" If yes, flag as a `question` — the struct may encode a meaningful distinction even with one field. Recommend an enum/const (`const localMode = ""`) or a comment at each call site to preserve intent.
