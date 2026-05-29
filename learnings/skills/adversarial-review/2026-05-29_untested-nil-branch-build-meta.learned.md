---
skill: wk-adversarial-review
date: 2026-05-29
type: gap
severity: medium
---

Untested nil/blank branch in a presence-guarded conditional

**What happened:** A bot review caught that a new helper method had no test for its nil-returning branch. The method used `<field>.present?` gating + `hash.presence` to return nil when the field was blank, but every existing spec provided a valid value, leaving the false branch entirely uncovered.

**Root cause:** Sweep 2.15 (workstyle) checks for missing sad-path tests on error-handling branches, but the adversarial pre-flight did not flag the symmetric nil-branch gap in presence-guarded builder methods. The pattern — `if x.present? ; hash[k] = x ; end ; hash.presence` — returns nil when no branch fires, and that return path needs explicit coverage.

**Suggested fix:** Add to sweep 2.15's missing-sad-path check: for any new method whose return type includes nil via `.presence`, grep the spec file for a test that stubs the controlling field to nil/blank and asserts the method (or its caller) receives `nil`. Flag as `suggestion` when absent; the nil path is behaviorally significant and silently brittle without it.
