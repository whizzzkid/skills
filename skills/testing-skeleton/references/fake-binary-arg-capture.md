---
class: principle
---

**Rule:** In fake shell-binary stubs, capture positional args into a named variable inside the arg-parsing loop; never `echo "$@"` after a shift-consuming `while` loop.

**Why:** `shift` mutates `$@` in place — once args are shifted out, `$@` is empty. `echo "$@"` after the loop is always a no-op, so the invocation log is never written and tests fail with a missing-file error rather than a meaningful assertion failure.

**Where:** Stage 3 — "Capture args inside the loop in fake shell-binary stubs."
