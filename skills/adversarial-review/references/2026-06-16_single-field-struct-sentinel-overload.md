---
class: principle
date: 2026-06-16
---

- **Rule:** When collapsing a single-field options struct to a plain param,
  check whether the field's zero-value reaches 2+ callers for different
  semantic reasons before clearing the "premature abstraction" fix.
- **Why:** A bare zero-value (`""`/`0`/`false`/`nil`) merges two distinct
  states the struct's named-field syntax used to keep visible.
- **Where:** Sweep 2.7 (signature widening) — single-field-struct collapse.
