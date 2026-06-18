---
class: principle
skill: wk-adversarial-review
date: 2026-06-18
---

**Rule:** After any refactor that moves logic inline (e.g. a validation helper
replaced by per-field inline sanitization), sweep the old helper: grep its name
in non-test files. Zero non-test callers → dead code. Delete it and rewrite its
tests against the live caller, so tests assert the path that actually runs.

**Why:** An inline refactor that leaves the helper in place creates two divergent
implementations. Tests keep asserting the dead helper's behavior while the live
contract goes untested; future drift between the two is silent.

**Where:** Step 2 sweep 2.17 (call↔definition existence) — the inverse case:
a definition kept with no live caller. General checklist item: "for each helper,
confirm at least one non-test caller."
