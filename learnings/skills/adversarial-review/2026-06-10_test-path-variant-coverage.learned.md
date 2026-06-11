---
skill: wk-adversarial-review
date: 2026-06-10
type: gap
severity: medium
---

Test-only commits need coverage-completeness audit across all producer-path variants of the function under test.

**What happened:** First adversarial review of a bats test commit passed with two suggestions but missed that the new tests only exercised the `.exports/` code path of a function that derives a file location via `dirname`. The top-level fallback path (a different `dirname` result) was untested. The gap was caught only in the second adversarial pass after a re-commit.

**Root cause:** The adversarial subagent's coverage check scanned for test function presence but did not enumerate the distinct code paths through the production function and verify each was exercised.

**Suggested fix:** For test-only commits, the adversarial subagent should explicitly: (a) identify the number of distinct code paths through each function the new tests target, and (b) verify at least one new test exercises each distinct path. Flag any unexercised path as a suggestion.
