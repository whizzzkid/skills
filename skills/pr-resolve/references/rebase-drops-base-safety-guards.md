---
class: principle
---

**Rule:** After resolving each base-advance rebase conflict, audit both sides for signal/context/cleanup primitives present on the base (HEAD) side but absent from the resolved result; restore any dropped guard.

**Why:** The base side is canonical `origin/<base>` state — a guard there (`signal.Stop`, `context.Cancel*`, `defer`, `close(`, `os.RemoveAll`, resource releases) was added intentionally by a prior merged PR. Taking the incoming commit's side can silently drop it; the code still compiles and tests pass, so the regression escapes everything but adversarial review.

**Where:** Step 2, after the `git rebase --onto` block. Mirrors wk-adversarial-review sweep 2.46.
