---
skill: wk-workflow
date: 2026-05-15
type: gap
severity: high
---

Phase 4 adversarial review did not flag that `runValidate` called `os.Exit` in five branches with zero tests.
The bot caught it as a Major finding on the next cycle.

**What happened:** `runValidate` was written as a main-style function that calls `os.Exit` directly. The adversarial
reviewer checked whether existing functions had test coverage but did not ask "is this new function even testable
without a subprocess?" — so no gap was surfaced. The fix required extracting `validateConfig(repoPath, skillsDir
string) ([]string, error)` as a testable inner function, a non-trivial refactor that landed post-review.

**Root cause:** The Phase 4 checklist covers "test coverage gaps" but the check is framed as "do tests exist" rather
than "can tests exist." Functions that call `os.Exit`/`log.Fatal` directly cannot be unit-tested without either a
subprocess or a refactor — this structural untestability was not a named check.

**Suggested fix:** Add to Phase 4 adversarial review checklist: "For every new function added in this PR, check
whether it calls `os.Exit`, `log.Fatal`, or `os.Exit(0)` directly. If yes, flag it: the function is untestable
as written and must be split into a testable `(result, error)` inner function + thin exit-handling wrapper before
coverage can be added."
