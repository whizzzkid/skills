---
class: principle
---

**Rule** — Any variable a script-scope EXIT trap is meant to clean up must be declared at script scope, not `local` inside a function. Initialize it to `""` before the first function call, or register tempfiles into a global array the trap iterates.

**Why** — Bash `local` scope is tied to the function's lifetime. A script-level `trap '... "$f" ...' EXIT` runs after functions return, so a `local f` set inside a function is out of scope at trap time and expands empty. A `${f:-}` guard silently swallows the bug — no error, just no cleanup — and the tempfile leaks on SIGINT/SIGTERM between `mktemp` and the next explicit `rm`.

**Under `set -u`** — the out-of-scope variable is not merely empty: the trap aborts with `<var>: unbound variable`
after the script's output has printed, so output looks right while the exit status is non-zero.

**Where** — Applied at authoring time, when the `trap` is written; review-time flagging is the backstop. Flag any
`trap` referencing a variable that is `local` where it's assigned.

**Escalation record** — 2026-11-25: re-violated while authoring a new script (rule read as review-only); escalated
baseline → `**Important:**` and given an authoring check. See
[`2026-11-25_exit-trap-local-at-authoring.md`](2026-11-25_exit-trap-local-at-authoring.md).
