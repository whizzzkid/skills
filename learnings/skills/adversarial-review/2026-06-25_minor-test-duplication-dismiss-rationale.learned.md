---
skill: wk-adversarial-review
date: 2026-06-25
type: pattern
severity: low
---

Test setup duplication and test-scope findings are often valid dismissals when tests cover distinct aspects and isolation value outweighs DRY.

**What happened:** A bot flagged two Minor findings on a new test function: (1) duplicated setup boilerplate shared with a sibling test, (2) a 7-char length assertion testing a called function's truncation behavior rather than just the caller's postcondition.

**Root cause:** Both findings are technically correct but miss the intent. Explicit self-contained setup improves test readability at the cost of some duplication — the tradeoff favors isolation for small test files. The length assertion is integral to the integration-level contract being locked, not incidental coverage of the called function.

**Suggested fix:** When evaluating test-duplication and test-scope bot findings, first assess whether the "duplicated" setup is genuinely shared (candidate for helper) or each test is self-describing standalone. If standalone, dismiss with the isolation rationale. For scope findings, check whether the assertion targets the integration behavior (correct site) or only the inner function (should move).
