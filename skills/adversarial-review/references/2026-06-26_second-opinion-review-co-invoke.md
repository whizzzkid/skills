---
class: principle
---

**Rule:** Detect a configured second-opinion review integration (review binary on
`PATH` or env/config flag) and invoke it in the same turn as the adversarial sweep,
re-deriving the co-invocation from the integration's presence — not from a standing
rule in user config.

**Why:** A co-invocation rule that lives only in user config (an ambient memory item)
competes with context pressure and gets skipped; the second-opinion review then runs
only in CI post-push, too late to block a broken push and adding a fix cycle.
Mechanical detection at a numbered step always executes.

**Where:** Step 2 mechanical sweep — escalation of the existing "run any repo-local
automated-review tool as an explicit sweep" rule (it was generic; the re-violation
made the second-opinion case explicit and mechanical).
