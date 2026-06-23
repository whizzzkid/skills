---
skill: wk-bash
date: 2026-06-23
type: surprise
severity: high
---

Bash 3.2 (macOS default): registering an EXIT trap before a `:?` expansion resets the exit code to 0, silently swallowing the error.

**What happened:** A script used `${BUILD_VERSION:?message}` to guard an empty variable. An EXIT trap was registered earlier in the same script. On bash 3.2 (macOS), the trap fires on `:?` expansion failure but resets `$?` to 0 before the trap body runs, so the script exits 0 instead of 1 — the guard silently passes.

**Root cause:** Bash 3.2 EXIT trap handling resets the exit code when triggered by a parameter expansion error. This is a known bash 3.2 regression not present in bash 4+. The pattern works on Linux CI (bash 4/5) but fails silently on macOS.

**Suggested fix:** Replace `:?` guards with explicit `if [[ -z "$VAR" ]]; then echo "..." >&2; exit 1; fi` — this is unambiguous across bash versions and is not affected by trap ordering.
