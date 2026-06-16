---
skill: wk-adversarial-review
date: 2026-06-16
type: pattern
severity: low
---

Parameterized integration tests that iterate over all nil-producing paths of an internal helper duplicate unit test concerns; one representative case suffices at the integration boundary.

**What happened:** A parameterized integration test iterated over three cases (missing file, empty file, unparseable value) to verify that a script routes nil → tier-50 nudge. A bot reviewer flagged that the three error paths were already unit-tested in the helper's spec, and that the integration boundary only needs one nil-producing case to verify the routing contract.

**Root cause:** When a nil-producing helper has thorough unit coverage, adding multiple integration cases for each nil source tests the helper's internals a second time rather than the integration contract. The adversarial review sweep did not include a check: "do the new integration test cases duplicate existing unit test coverage for the same nil-producing helper?"

**Suggested fix:** Add a sweep item: after reviewing new parameterized integration tests, grep for existing unit tests of any helper called by the integration path; if the unit suite already asserts all the parameterized cases return the same value, flag the redundant iterations as a suggestion (keep one representative case at the integration layer).
