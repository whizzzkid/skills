---
skill: wk-adversarial-review
date: 2026-06-01
type: pattern
severity: high
---

Test shim that duplicates security-sensitive production code is a high-priority finding class.

**What happened:** A BATS test extracted security-sensitive functions
(`collect_artifacts`, `_under_target_root`) into an inline heredoc shim.
This was correctly flagged as a code-duplication risk — a patch to the
production symlink-escape guard would leave the test validating stale logic.
The fix was to extract both functions to a shared lib sourced by both callers.

**Root cause:** The test was written to be self-contained (no external
dependencies), which caused it to copy rather than source the functions.
The duplication risk was non-obvious because the shim was syntactically
identical, not semantically different.

**Suggested fix:** Add to sweep 2.15 (workstyle) or a new sweep: for each
multi-line heredoc in a test file that defines a function also present in
the diff's source files, flag as `code-duplication` with severity `major`
when the duplicated function contains security-sensitive logic (symlink
guards, credential redaction, path traversal checks). The detection pattern:
grep test files for function definitions (`<name>()`) that also appear in
production source.
