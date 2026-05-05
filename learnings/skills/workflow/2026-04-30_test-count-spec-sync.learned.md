---
skill: wk-workflow
date: 2026-04-30
type: gap
severity: medium
---

When adding a test, update the spec's test enumeration/count in the same commit.

**What happened:** PR #NNN's spec testing section enumerated 7 bats tests for `setup_env.sh`. When a reviewer caught a missing parallel test and a new test was added, the spec was not updated to list 8. {bot} caught this in the next review round with a Minor finding.

**Root cause:** The test was added to the `.bats` file but the spec doc that described "what tests exist and why" was not touched, leaving the count/list stale.

**Suggested fix:** After adding any test, grep the spec for the test file name or the function name and check if the spec enumerates tests. If so, update the spec's test list in the same commit. The invariant is: spec test counts and bullet lists must always match the actual test file. A one-line diff to the spec is faster than a second review round.
