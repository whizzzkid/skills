---
class: principle
---

# Multi-branch diagnostics must key on the real discriminant

**Rule:** When a check has multiple failure branches emitting distinct messages,
each branch keys on the actual failure mode, not a correlated proxy variable.
Collapsing two distinct failure modes into one guard and branching on a proxy
fires a misleading message on the orthogonal failure.

**Why:** A guard branched on stderr emptiness reported "output format may have
changed" when the format was fine and the file was simply absent — the proxy
(stderr) did not track the real discriminant (parse result vs file existence).

**Where:** Step 2 mechanical sweep 2.55(b). Give each distinct failure mode its
own condition and message; never branch on a proxy when the discriminant is
available directly.
