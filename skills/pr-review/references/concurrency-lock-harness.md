---
class: principle
---

# Concurrency/lock harness construction (Phase 3)

Relocated from `SKILL.md` Phase 3 to hold the body under its size ceiling. The rule (real separate connections; a
single-connection spec is never a faithful harness; compare against a mutant) stays inline; this file carries the
construction recipe.

## Winner/losers harness

- Run a script through the framework's runner, never a transactional-fixture spec.
- One winner holds the conflicting write uncommitted.
- N losers each check out their own connection inside an outer transaction and call the real method.
- Compare against a mutant (lock variant, or the change reverted) — identical results mean the probe cannot see the
  effect.
- Delete the probe's rows afterwards.

## Stale-snapshot claims

- Non-locking pre-check mixed with a locking write → one connection opens a transaction and reads, another commits the
  conflicting change, then the first calls the method.
- Run on head and on the pre-check-removed mutant, then restore the file from a pre-mutation copy (never via VCS).

**Why** — a single connection inside one snapshot cannot observe cross-transaction locking; a mutation that dropped the
lock stayed green under it.

**Where** — `SKILL.md` → Phase 3, under the HARD RULE "logic-bearing findings need empirical proof".
