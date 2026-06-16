---
skill: wk-adversarial-review
date: 2026-06-16
type: correction
severity: high
---

Named-return deferred cleanup is silently defeated by explicit `return "", err` statements.

**What happened:** A refactor converted a function from explicit returns to named returns + deferred cleanup. The deferred func called `os.RemoveAll(dir)` on error. However, all error paths used `return "", fmt.Errorf(...)` — the explicit `""` sets the named `dir` to `""` *before* the deferred function runs, causing `os.RemoveAll("")` (a no-op in Go). The actual temp dir leaked on every error path. The function comment claimed "named returns allow deferred cleanup to remove the partial dir on any error path", which was precisely wrong.

**Root cause:** Go spec: a `return` statement with explicit values *sets the named return variables* before deferred functions execute. `return "", err` → `dir = ""` → defer sees `dir == ""` → no-op RemoveAll. The developer (and initial reviewer) assumed the existing `return "", err` patterns were safe once a defer was added, without verifying the Go semantics.

**Suggested fix:** Add a mechanical sweep check: when a function uses named returns with a deferred cleanup that reads a named return, grep all `return <zero-literal>, ...` statements in that function (after the defer is established) and flag them as suspect. The correct pattern after the defer is established is: `err = fmt.Errorf(...); return` (bare return), not `return "", fmt.Errorf(...)`. This keeps the named `dir` at its real value so the deferred cleanup can use it.
