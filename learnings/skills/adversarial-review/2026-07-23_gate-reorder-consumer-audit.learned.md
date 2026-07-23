---
skill: wk-adversarial-review
date: 2026-07-23
type: gap
severity: medium
---

Reordering a guard in an early-return dispatch silently breaks downstream consumers that switch on the resulting reason/enum.

**What happened:** A guard was moved ahead of a peer in an early-return gate
sequence (a decision function returning `[reason_string, reason_symbol]`). That
made a previously-unreachable reason symbol newly reachable for one input class.
A downstream consumer (a separate script) `case`d on that symbol but had no
branch for it, so it fell through and silently dropped a user-visible
annotation. The decision function's own spec asserted only the returned symbol
value and passed clean — it never exercised the consumer's `case`, so the gap
was invisible until a spec shelled out to the real consumer.

**Root cause:** No sweep step ties a gate/branch reorder to an audit of every
downstream consumer that switches on the reordered output. A green unit test on
the producing function is not evidence the consuming `case`/`switch` handles the
newly-reachable value — the mutation-test standard (delete the new branch → does
any test go red?) would have caught it, but nothing prompted running it against
the consumer.

**Suggested fix:** Add a sweep trigger: when a diff reorders guards/cases in an
early-return or first-match dispatch, grep for every consumer that switches on
the produced reason/enum/status and confirm each has a branch for any
now-reachable value (and no dead branch for a now-unreachable one). Treat a spec
that asserts only the producer's return value as NOT covering the consumer's
dispatch — require a test that drives the real consumer for the newly-reachable
value, or flag the consumer branch as untested.
