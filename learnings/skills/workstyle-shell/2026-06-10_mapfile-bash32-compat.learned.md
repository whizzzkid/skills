---
skill: wk-workstyle-shell
date: 2026-06-10
type: gap
severity: high
---

Hooks and scripts must be written for macOS system bash (3.2), which lacks `mapfile`.

**What happened:** A pre-commit hook was written using `mapfile -t arr < <(...)` which is bash 4+ only. On macOS the default `/bin/bash` is 3.2, so the hook failed with `mapfile: command not found` on the first commit that triggered it.

**Root cause:** The shell best-practices check in wk-workstyle-shell does not explicitly call out `mapfile` as a bash 4+ construct unavailable on the macOS system shell.

**Suggested fix:** Add a rule: never use `mapfile` in hooks or scripts expected to run under the macOS system bash; replace with a `while IFS= read -r line; do ... done <<< "$var"` or a plain `while read` loop. When in doubt, test the script explicitly under `/bin/bash` (3.2) before committing.
