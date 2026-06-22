---
skill: wk-adversarial-review
date: 2026-06-22
type: pattern
severity: medium
---

Fake CLI stubs should gate conditional output on the flag that enables it in production

**What happened:** A fake `curl` stub in a test helper unconditionally wrote the response body to the `-o` target file, regardless of whether `--fail-with-body` was present. The test "asserts response body appears in error output on HTTP failure" would have passed even if the production script regressed from `--fail-with-body` back to plain `-f` — the exact regression the test was meant to catch.

**Root cause:** The stub was written to mimic the happy-path shape (writes body → gets cat'd in error handler) without encoding the flag precondition. The stub should model both the present-flag and absent-flag behaviors to make the regression testable.

**Suggested fix:** When reviewing or generating fake CLI stubs, check: does the stub write output unconditionally that production only writes under a specific flag? If so, add a branch in the stub gating the output on presence of that flag in `$@`. Pattern: `has_flag=false; for a in "$@"; do [[ "$a" == "--the-flag" ]] && has_flag=true; done; $has_flag && write_output || skip`. This makes the stub a contract-enforcing gate, not just a shape-mimicker.
