---
class: principle
skill: wk-adversarial-review
date: 2026-06-16
severity: high
---

**Rule:** When a function uses named returns plus a deferred cleanup that reads
a named return, flag every `return <zero-literal>, ...` statement after the
defer is established. An explicit `return` sets the named returns to those
values *before* deferred functions run, so the cleanup sees the zero value
(e.g. `os.RemoveAll("")` → silent no-op → leaked resource).

**Why:** The Go spec assigns explicit return values to the named return
variables before deferred functions execute. Adding a defer to a function that
still uses `return "", err` does not make the cleanup work — the named variable
is already zeroed. The bug is invisible (no error, just a leak) and any comment
claiming "cleanup runs on any error path" is then false.

**Where:** Step 2 Mechanical Sweep Catalog → sweep 2.36. Fix: assign then
bare-return (`err = ...; return`).
