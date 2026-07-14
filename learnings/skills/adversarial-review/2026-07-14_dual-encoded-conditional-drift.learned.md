---
skill: wk-adversarial-review
date: 2026-07-14
type: pattern
severity: medium
---

A bot review flagged a case where two call sites independently re-derive the same conditional (e.g. "is this level in set X") instead of one deriving it from the other's return — worth adding as a named sweep pattern.

**What happened:** A helper function mapped a stored value to an effective value based on a condition, and returned only the mapped value (a bare scalar). A caller needed to know *whether* the mapping had actually applied the condition (to decide whether to skip a later step), so it independently re-checked the same condition via a separate membership test against the same underlying set the helper's `match` arms already encoded. This passed all tests and compiled fine, but created two independent encodings of one rule that could silently diverge if the rule's input set ever changed in one place and not the other. Fixed by changing the helper to return `(value, condition_met)` so the caller reads the fact directly instead of re-deriving it.

**Root cause:** No sweep in the catalog specifically looks for "a caller re-derives a condition its own callee already computed and discarded." The existing signature-widening sweep (2.7) checks call-site compatibility, not whether a richer return type would eliminate a duplicated fact.

**Suggested fix:** Add a sweep: when a function returns a bare scalar/bool and a caller immediately re-checks a condition against the same input that determined that scalar's value (grep for a second reference to the same constant/set/enum the callee's match arms use), flag as a potential drift risk — suggest widening the return type to carry the decision instead of re-deriving it.
