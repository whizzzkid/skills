---
skill: wk-workstyle-naming
date: 2026-06-11
type: correction
severity: medium
---

Never abbreviate descriptive variable names to initialisms or short aliases in any context.

**What happened:** A test array holding case-insensitivity test cases was named `ciCases` (initialism for "case-insensitive"). The user corrected it to `caseInsensitiveTestCases`.

**Root cause:** The naming rule "descriptive names" was applied to identifiers visible in production APIs but silently relaxed for test-local variables and one-off temporaries. This is a scope-dependent double standard — the rule has no scope exemption.

**Suggested fix:** Add an explicit rule to `wk-workstyle-naming`: full descriptive names are required in all scopes — test code, one-off locals, loop variables (except `i`/`j`/`k`), and inline temporaries. Initialisms (`ci`, `cb`, `pg`, `ts`) and short aliases that are not the established project convention are always wrong regardless of scope.
