---
class: principle
skill: wk-testing-skeleton
date: 2026-07-24
severity: medium
---

- **Rule:** An interactive verification probe run against the test database is a state
  mutation. Wrap it in an explicit always-rollback transaction, or re-prepare the test
  database immediately after the probe and before the next suite run. Treat an
  unexplained failure in a spec the current change does not touch as self-inflicted
  state pollution first, not a regression.
- **Why:** Framework runners commit by default, unlike the spec suite, which wraps each
  example in a rolled-back transaction — so the probe's writes survive into later runs.
  Leftover rows are indistinguishable from a fixture the suite never created, which
  makes the resulting failures read as genuine regressions in unrelated examples and
  buys a debugging detour that only clears on re-preparing the database.
- **Where:** The shared/global-state section — a sibling subsection covering out-of-suite
  write paths (runner invocation, console session, seed script, one-off migration).
- **Note:** Distinct from the existing shared-state rule, which covers state a *test*
  replaces at module/framework level and explicitly notes that transactional rollback
  does not reach it. This rule covers writes made entirely outside the suite, where no
  rollback exists at all.
