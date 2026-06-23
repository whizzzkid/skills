---
class: principle
skill: wk-workstyle-shell
date: 2026-06-23
---

**Rule**

Never guard an empty variable with `${VAR:?msg}` when an `EXIT` trap is
registered. Use an explicit `if [[ -z "${VAR:-}" ]]; then echo … >&2; exit 1; fi`.

**Why**

On bash 3.2 (macOS default) an `EXIT` trap firing on a `:?` expansion failure
resets `$?` to `0` before the trap body runs → the script exits `0` and the guard
silently passes. Works on bash 4/5 (Linux CI), fails silently on macOS.

**Where**

Rules list, beside the bash-3.2 targeting rule.
