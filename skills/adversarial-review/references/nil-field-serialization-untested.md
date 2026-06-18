---
class: principle
---

**Rule:** When a new struct field is serialized via `.to_s`/equivalent, the test set must include a nil/false/0 case, not just the non-nil happy-path values.

**Why:** The zero-value path through a serialization boundary is the common production path (silent skips, error rescues); a `NoMethodError` there escapes happy-path-only specs.

**Where:** Sweep 2.19a (extended).
