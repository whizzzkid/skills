---
class: principle
---

**Rule:** A partition predicate (the function that routes data into buckets)
reading a nilable field via bracket/`[]` access defers a nil error past the
decision point. Require strict access (`.fetch`/equivalent) in such predicates
so a missing field fails fast at the boundary, not later in a downstream
formatter. Separately, when a predicate and a gate consume the same field,
check whether they need independent constants even if the values are identical
today.

**Why:** Bracket access on a nilable field returns nil silently, so the record
routes to the wrong bucket and crashes downstream — far from the decision that
mishandled it. `.fetch` raises at the partition boundary, the earliest correct
failure site. Sharing one constant across a visibility predicate and an
approval gate conflates two concerns and causes review-bot thrash when the two
lists later diverge; the constant-decoupling angle is already covered by sweep
2.7 (overloaded zero-value across callers).

**Where:** wk-adversarial-review sweep 2.3 (merged the partition-predicate
strict-access clause into the existing nil/guard row). Constant decoupling →
reference only, covered by 2.7.
