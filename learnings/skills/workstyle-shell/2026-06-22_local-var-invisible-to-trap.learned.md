---
skill: wk-workstyle-shell
date: 2026-06-22
type: surprise
severity: medium
---

A bash `local` variable assigned inside a function is invisible to an EXIT trap set at script scope.

**What happened:** A script set `trap 'rm -f "$TOKEN_FILE" "${response_file:-}"' EXIT` at the top level, but `response_file` was declared `local` inside a `publish()` function. At trap-execution time (script exit, after all `publish()` calls returned), `response_file` was out of scope and always expanded to empty — the trap silently only ever cleaned `TOKEN_FILE`. The explicit `rm -f` calls inside the function covered normal-flow cleanup, but SIGINT/SIGTERM between `mktemp` and the next `rm` would have leaked the tempfile.

**Root cause:** Bash `local` scope is tied to the function's lifetime. Once the function returns, the local var is gone from the environment the trap sees at the script level. The `${var:-}` guard silently swallows the bug — no error, just no cleanup.

**Suggested fix:** For any tempfile that a script-level EXIT trap is meant to clean up, declare the variable at script scope (not `local`). Either initialize it to `""` before any function call, or use a global array of active tempfiles that functions register into, and the trap iterates over. When reviewing `trap` + `local` patterns, flag any trap that references a variable that could be `local` in the functions that set it.
