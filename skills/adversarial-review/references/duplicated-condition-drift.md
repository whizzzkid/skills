---
class: principle
---

**Rule** — Sweep 2.73: when a callee returns a bare scalar/bool derived from a
condition and a caller immediately re-checks that same condition against the same input
(a second reference to the constant/set/enum the callee's branches already encode) to
drive control flow, flag it. Widen the return to carry the decision (e.g.
`(value, condition_met)`) so the caller reads the fact instead of re-deriving it.

**Why** — Two independent encodings of one rule silently diverge when the input set
changes in one place only; it compiles and passes tests, so nothing catches it. Distinct
from 2.7 (call-site compatibility), which never asks whether a richer return type would
eliminate a duplicated fact.

**Where** — `references/sweep-catalog-extended.md` row 2.73; inline pointer list in
`SKILL.md`; README count 77→78.
