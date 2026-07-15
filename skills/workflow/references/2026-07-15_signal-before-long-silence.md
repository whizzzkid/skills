---
class: principle
---

**Rule:** Before any operation expected to exceed ~1 min (full test suite, CI
poll, repeated flake-confirmation runs), state what is running and its rough
expected duration; on a repeat, say why the repeat is needed.

**Why:** A long silent operation is indistinguishable from a stall — the user
reads normal latency as a hang and interrupts to ask whether the process is
stuck.

**Where:** wk-workflow Phase 6 (CI Fix Loop), folded into the background-watch
bullet. Applies to any long-running wait across phases.
