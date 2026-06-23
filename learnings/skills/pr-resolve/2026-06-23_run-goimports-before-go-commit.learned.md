---
skill: wk-pr-resolve
date: 2026-06-23
type: gap
severity: medium
---

Run goimports before committing any Go file — go test does not catch import grouping violations.

**What happened:** A new test function added a `"context"` import. The file was verified with `go test` (passed) and committed. CI failed on the Go Format Check step because `goimports` enforces import grouping (stdlib / external / internal) and the new import landed in the wrong group.

**Root cause:** Step 6's verification command was `go test`, which validates compilation and test correctness but not import ordering. The project's CI enforces `goimports -local <module>` as a separate format gate.

**Suggested fix:** After writing or editing any Go file, run `goimports -local <module> -l <file>` before staging. If output is non-empty, run `goimports -local <module> -w <file>` to fix in place, then re-verify tests pass. Add this as an explicit Step 6 pre-commit check for Go files alongside the standard build/test verification.
