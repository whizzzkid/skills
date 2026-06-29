---
class: principle
---

**Rule:** A missing security guard or input validation (SSRF, injection, path
traversal, scheme check) is blocker-class regardless of scope — apply it now.
Never propose deferring it to a follow-up without explicit user instruction.
Split a larger tooling replacement into a separate follow-up; the guard itself
is never the deferrable part.

**Why:** "Defer for follow-up" framing belongs to features, not guard clauses. A
security validation protects against injection/SSRF/traversal now; postponing it
ships the vulnerability. Conflating a valid tooling-swap follow-up with the guard
fix lets the guard slip. "Apply guard now, track the larger replacement
separately" is always the right split.

**Where:** Phase 4 (Adversarial Review), finding-triage handling.
