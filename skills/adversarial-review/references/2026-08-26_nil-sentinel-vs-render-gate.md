---
class: principle
source: learnings/skills/adversarial-review/2026-08-26_nil-sentinel-vs-render-gate.md
---

# Nil sentinel vs render-gate: sweep 2.91

A new validation branch that returns an empty/nil sentinel must be re-checked
against every consumer's render/gate predicate, not just unit-tested in
isolation.

**Mechanism:** A derived value gates a hazard. The fix adds input validation
that returns nil for an invalid input. But the predicate deciding whether the
consumer renders only tests non-emptiness — so the consumer still renders
while the key is nil, using a random/default value where a deterministic one
was required. The nil sentinel is produced on a path where the consumer is
live.

**Invariant to pin:** non-nil whenever the consumer renders. Never pin the
regression (asserting nil) — that tests the wrong property.

When a nil branch is unassertable through the test helper (the helper raises
when the consumer does not attach), cover the actual safety property instead
(the consumer attaches nothing on that path).
