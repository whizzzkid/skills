---
skill: wk-adversarial-review
date: 2026-08-26
type: gap
severity: high
verified-against-source: yes
---

A new validation branch that can return an empty/nil sentinel must be re-checked against every consumer's render/gate predicate, not just unit-tested in isolation.

**What happened:** A derived value gated a hazard — a stable selection key decided which credential-bearing app every pipeline step used; only the app that *created* a check-run may *modify* it. A round-1 fix added input validation (numeric-PR + slug-format checks) that returned `nil` for a non-empty-but-non-numeric input (a literal `"false"` that config docs wire from a non-PR build var). But the predicate deciding whether the vulnerable steps *render* only tested non-emptiness — so those steps still rendered while the key was `nil`, and each step drew a random app, reintroducing the exact identity-mismatch bug the change existed to kill, on a **newly introduced** path (worse than pre-fix, which returned a stable-if-ugly key). A first-round review that reasons only about the diff's own logic misses this; the delta review caught it by independently re-deriving the *render* predicate and comparing it to the *nil-return* condition.

**Root cause:** The mechanical sweeps (2.3 dead-guard, 2.90 dead-skip) look at a guard's own reachability, but there was no sweep step that pairs a *new sentinel-returning branch* with the *separate* predicate that decides whether the sentinel's consumer runs. A sentinel is only safe if it can never be produced on a path where the consumer is live.

**Suggested fix:** Add an adversarial stance / sweep row: "When the diff adds or narrows a branch returning an empty/nil/zero sentinel, locate every consumer and the predicate that decides whether that consumer executes; confirm the sentinel is unreachable whenever the consumer is live. If they can disagree, that is a blocker." Pair with a test-quality note: pin the *invariant* (non-nil whenever the consumer renders), never the *regression* (asserting nil). And when a nil branch is unassertable through the test helper (the helper raises when the consumer does not attach), cover the actual safety property instead (the consumer attaches nothing on that path), rather than leaving it uncovered.
