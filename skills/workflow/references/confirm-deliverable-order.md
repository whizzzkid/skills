---
class: principle
---

# Confirm the order of bundled deliverables

**Rule** — When a prompt lists multiple deliverables and leaves their sequence
implicit, enumerate the deliverables AND their execution order. State the
intended sequence in one line before the first write-action so the user can
redirect cheaply.

**Why** — Enumerating deliverables alone still lets the agent pick the wrong
starting item; the user then interrupts mid-implementation to reorder, wasting
the work already begun. A one-line up-front sequence makes a redirect cheap.

**Where** — `wk-workflow` Continuity Rules (the enumerate-every-deliverable
bullet).
