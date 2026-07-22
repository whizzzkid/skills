---
class: principle
---

- **Rule**: While a background CI poll runs, start the next plan task that has no
  dependency on the in-flight PR's green state; the poll re-invokes you on
  completion. Hard-wait on CI only when nothing else can progress (last PR in the
  stack, or a step genuinely needs green — auto-merge, or a later stacked PR that
  must build on this one). Interleaving the tail of PR N with the body of PR N+1
  is the default, not the exception.
- **Why**: The PR lifecycle reads as a linear push → self-review → poll → ready
  sequence, so the agent idles on the CI barrier even when independent plan items
  could progress. The poll already runs in the background and notifies on
  completion; blocking on it wastes wall-clock.
- **Where**: wk-workflow Phase 6 (CI Fix Loop), background-watch bullet.
