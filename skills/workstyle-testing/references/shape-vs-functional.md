---
class: principle
---

**Rule:** Never let a structural/shape assertion (a config or data value equals
an expected literal) stand in for proof a feature works. Validate a feature by
driving it end-to-end through its real entry point (HTTP request, public method)
against real values, with no stub of the path under test (e.g.
`and_call_original`), asserting the observable outcome plus a negative case.

**Why:** A shape assertion proves the input *looks* right, not that the
parse → lookup → compare path runs. It still passes when the real path is broken
— wrong lookup key, type mismatch, comparison bug, unregistered key. That tests
the fixture, not the behavior.

**Where:** The behavior-over-implementation rule in `SKILL.md`. Reserve shape
assertions for genuine schema-contract tests only.
