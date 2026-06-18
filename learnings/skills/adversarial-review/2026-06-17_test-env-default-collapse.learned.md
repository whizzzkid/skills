---
skill: wk-adversarial-review
date: 2026-06-17
type: gap
severity: medium
---

Partial-unset test collapses to identical assertion as both-unset test when harness default matches script default.

**What happened:** New URL construction tests were written for a script that reads two env vars with defaults (account=`<DEFAULT_ACCOUNT>`, repo=`<DEFAULT_REPO>`). Test 2 unset only the repo var; test 3 unset both. The test harness already supplied the same account value as the script's own fallback, so both tests produced the same assertion and neither proved the other var's fallback worked independently.

**Root cause:** The test harness `run_script` default env matches the script's own `ENV.fetch` fallback for the partial-unset case. The missing-var code path technically fires but the observable output is identical to the explicit-default case, so the test is tautological.

**Suggested fix:** In the test-coverage sweep (2.15), when new env-var-fallback tests are added, check whether the harness's base env supplies any of the tested vars at the same value as the script's own fallback. If so, flag the partial-unset test as potentially redundant unless the explicit-unset test uses a non-default value for the other variable to make each case's assertion distinct.
