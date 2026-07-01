---
class: principle
---

**Rule:** Before grilling, when a prompt may describe work already underway or
complete (re-fired/looped prompt, "continue X", resumed session) → verify
current state first (open/merged PR, ticket status, artifact present). Already
complete → report and stop; never re-execute finished work.

**Why:** A looped/stale prompt is indistinguishable from a fresh one at the text
level; an instruction to "continue X, then PR" fired again after X was merged
and the pipeline nearly re-ran.

**Where:** wk-plan Step 0 "Already-done pre-check".
