---
class: principle
---

**Rule** — Any variable a script-scope EXIT trap is meant to clean up must be declared at script scope, not `local` inside a function. Initialize it to `""` before the first function call, or register tempfiles into a global array the trap iterates.

**Why** — Bash `local` scope is tied to the function's lifetime. A script-level `trap '... "$f" ...' EXIT` runs after functions return, so a `local f` set inside a function is out of scope at trap time and expands empty. A `${f:-}` guard silently swallows the bug — no error, just no cleanup — and the tempfile leaks on SIGINT/SIGTERM between `mktemp` and the next explicit `rm`.

**Where** — Shell-script review. Flag any `trap` referencing a variable that is `local` where it's assigned.
