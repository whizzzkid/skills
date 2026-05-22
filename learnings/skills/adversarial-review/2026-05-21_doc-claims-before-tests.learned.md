---
skill: wk-adversarial-review
date: 2026-05-21
type: gap
severity: medium
---

Spec doc claimed "tests verify X" before a test verifying X existed.

**What happened:** The observability spec was written stating "tests verify context attributes appear as flat JSON fields — not as ddtags." No spec case existed that made this assertion. Adversarial review caught it as a blocker (spec-vs-implementation divergence).

**Root cause:** Doc was written to describe intended test coverage as if it already existed. The doc and the tests were written in the wrong order.

**Suggested fix:** Add a sweep to the adversarial review that greps spec docs for phrases like "tests verify", "a test confirms", "spec asserts", "unit tests assert" and cross-checks that a corresponding test function exists in the relevant spec file. Flag as blocker if the claim is unverified.
