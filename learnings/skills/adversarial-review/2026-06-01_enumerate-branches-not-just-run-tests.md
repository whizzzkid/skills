---
skill: wk-adversarial-review
date: 2026-06-01
type: correction
severity: high
---

Sweep 2.15 must enumerate every branch of each new function and cross-check against test names — running the suite green is not sufficient.

**What happened:** A new multi-branch function (11 return paths) was added to the diff. The adversarial review ran the test suite (passed) and checked for stale comments, but did not enumerate the function's branches and verify each had a named test exercising it. 4 return paths had no test. A bot reviewer caught this after push.

**Root cause:** Sweep 2.15 (Workstyle pass) lists "Missing sad-path tests for new error-handling branches" but in practice was satisfied by a green test run. The sweep must be applied mechanically: count `if/else/return` branches in each new function in the diff, then count matching test functions, and flag any branch with no test.

**Detection sketch:** For each new function in the diff, count distinct `return` statements. Then grep test files for `func Test<FunctionName>_` variants and verify the count of test-function variants is ≥ the number of `return` statements. Flag the delta as a blocker if any return path has no covering test. Confidence: high (mechanical — countable from the diff).

**How to apply:** In sweep 2.15, after listing undocumented public functions, add a required sub-step: for every new multi-branch function (>2 return paths), enumerate branches vs test coverage. A green suite does not imply full branch coverage — the sweep must do the branch math explicitly.
