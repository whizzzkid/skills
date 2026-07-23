---
class: principle
---

**Rule** — When a diff reorders guards/cases in an early-return or first-match
dispatch that returns a reason/enum/status, grep every downstream consumer that
`case`/`switch`es on the produced value and confirm each handles every
now-reachable value (and carries no dead branch for a now-unreachable one). A
spec asserting only the producer's return value does not cover the consumer's
dispatch — require a test that drives the real consumer with the newly-reachable
value.

**Why** — Reordering a guard can make a previously-unreachable reason value newly
reachable for one input class. A downstream consumer switching on that value with
no matching branch falls through silently and drops user-visible output. A green
producer-side unit test never exercises the consumer's `case`, so the gap is
invisible; the mutation-test standard (delete the consumer branch → any test go
red?) would expose it, but nothing prompts running it against the consumer.

**Where** — Extended sweep catalog row 2.85. Complements 2.37, which covers the
inverse (now-unreachable *calls* + missing `not_to receive` assertions); 2.85
covers a newly-reachable *return value* a downstream switch fails to handle.
