---
skill: wk-workflow
date: 2026-05-15
type: gap
severity: medium
---

Phase 4 adversarial review fixed the early-return-on-first-violation bug in `CheckAlphabeticalOrder` but did
not notice that the same function swallowed all `os.ReadFile` errors — inconsistent with `ValidateRepoChecks`
two functions away. The bot caught it as a Minor error-handling finding on the next cycle.

**What happened:** `ValidateRepoChecks` explicitly distinguishes `os.IsNotExist` (return nil) from other I/O
errors (return error string). `CheckAlphabeticalOrder`, added in the same PR, silently returned nil for all
`os.ReadFile` errors including permission-denied and I/O failures. The reviewer audited internal logic but never
compared the error-handling pattern to sibling functions operating on the same filesystem paths.

**Root cause:** The Phase 4 error-handling check is "does this function handle errors?" — it passes once any
`err != nil` branch exists. It does not ask "is this function's error-handling contract consistent with sibling
functions that do the same operation?"

**Suggested fix:** Add to Phase 4 adversarial review: "For new functions that handle file I/O errors, grep the
same package for other functions reading similar paths (`grep -n 'os.ReadFile\|os.ReadDir\|os.Open' <package>`)
and verify the error-handling pattern is consistent — same IsNotExist/other-error split, same return convention."
