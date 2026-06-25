---
class: one-off
---

**Scenario:** A bot flags Minor findings on a new test function — duplicated setup
boilerplate shared with a sibling test, and a length assertion testing a called
function's behavior rather than only the caller's postcondition.

**Symptom:** Findings are technically correct but miss intent: explicit
self-contained setup improves readability at the cost of some duplication, and the
assertion is integral to the integration-level contract being locked.

**Fix:** For test-duplication findings, assess whether the "duplicated" setup is
genuinely shared (helper candidate) or each test is self-describing standalone —
if standalone, dismiss with the isolation rationale. For test-scope findings,
check whether the assertion targets integration behavior (correct site) or only
the inner function (should move).

**Why not promoted:** Low severity, narrow judgment pattern. Already covered in
spirit by sweep row 2.15 (test-dedup audit) and existing references
(`integration-vs-unit-test-scope.md`, `shared-examples-coverage-gaps.md`,
`relocated-code-severity-downgrade.md`); adversarial-review SKILL.md is at the
size ceiling. No SKILL.md edit.
