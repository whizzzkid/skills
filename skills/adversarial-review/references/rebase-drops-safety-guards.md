---
class: principle
---

**Rule:** After resolving a merge/rebase conflict at a call site, diff both sides for signal/context/cleanup primitives present on the base/HEAD side but absent from the resolved result; restore any dropped guard.

**Why:** Base state is canonical — a guard there (`signal.Stop`, `context.Cancel*`, `defer`, `close(`, `os.RemoveAll`) was added intentionally. Taking the incoming side can drop it silently; the code still compiles and tests pass, so the regression escapes everything but adversarial review.

**Where:** Sweep 2.44 (extended). Mirrored in wk-pr-resolve Step 2.
