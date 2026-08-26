---
skill: wk-buildkite
date: 2026-08-25
type: correction
severity: medium
verified-against-source: yes
---

Claimed a CI fix "should pass" twice in a row without waiting for and checking the actual build result, and both claims were wrong.

**What happened:** After pushing a fix for a failing spec, the agent reported the build "should pass now" while the build was still running or before re-checking. The next build failed for a different reason each time (a follow-on regression, then a linter violation on the fix itself). The user had to call this out twice before the agent stopped predicting outcomes and started verifying them.

**Root cause:** The agent treated "I understand why the previous failure happened and pushed a fix for it" as equivalent to "the build will pass," without accounting for the fix itself introducing a new failure mode. This is a forecast, not a checked fact, and CI has multiple independent gates (tests, linters, type-checkers) any one of which can fail even when the specific bug is fixed.

**Suggested fix:** Never state or imply a build outcome ("should pass," "this should fix it") as if it were confirmed. After every CI-directed push, explicitly fetch and report the actual build/job state before making any claim about pass/fail — treat an unfetched build as unknown, not passing.
