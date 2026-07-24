---
skill: wk-testing-skeleton
date: 2026-07-24
type: gap
severity: medium
---

Ad-hoc verification scripts run against the test database leave rows behind and
produce phantom spec failures later in the session.

**What happened:** To validate a new clamping helper against real schema limits,
the agent ran a handful of throwaway probe scripts through the framework's
runner in the test environment. Those writes persisted, and a later full spec run
failed three unrelated examples that assumed an empty table. The failures looked
like real regressions and cost a debugging detour; they cleared only after
re-preparing the test database.

**Root cause:** No rule covering ad-hoc probes as a state mutation. Framework
runners commit by default — unlike the spec suite, which wraps each example in a
rolled-back transaction — so a probe is indistinguishable from a fixture the
suite never created.

**Suggested fix:** When verifying behavior interactively against a database,
either wrap the probe in an explicit transaction that always rolls back, or
re-prepare the test database immediately after the probe and before the next
suite run. Treat an unexplained failure in a spec the current change does not
touch as a self-inflicted state-pollution signal first, not a regression.
