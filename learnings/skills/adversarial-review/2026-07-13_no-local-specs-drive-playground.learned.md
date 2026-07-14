---
skill: wk-adversarial-review
date: 2026-07-13
type: correction
severity: medium
---

During PR review, don't re-run the project's existing test suite locally — CI already runs it; spend that effort driving the changed code through failure scenarios in the review-playground instead.

**What happened:** The investigation ran `bundle exec rspec` on the changed spec files to confirm they pass. This duplicated work CI already does, and a green local suite adds nothing the author didn't already see — while a red one is often environmental (wrong interpreter, missing service) rather than a real PR defect.

**Root cause:** The skill treated "run the specs" as a validation step. But the suite's pass/fail is authoritative on CI, not locally. Local runs cost wall-clock and risk misclassifying environmental failures as PR findings; they also don't test the failure modes the change actually introduces (they test the happy paths the author already covered).

**Suggested fix:** In the playground phase, do not run the full/existing test suite to establish correctness — treat CI as the source of truth for suite pass/fail. Reserve local effort for adversarially exercising the change's failure scenarios directly: drive the modified code paths with hand-crafted inputs that hit timeouts, exhausted retries, malformed/partial responses, degraded-dependency conditions, and non-zero exit codes, and observe real behavior. Verify by driving the code, not by re-running the suite. (Running a single new test to reproduce a specific suspected defect is fine; running the suite for general validation is not.)
