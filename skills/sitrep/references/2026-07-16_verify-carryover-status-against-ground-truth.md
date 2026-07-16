---
class: principle
---

**Rule:** Treat a gathering agent's reported cross-system status (e.g. a
ticket's linked-PR state) as a claim to verify, not a fact. Re-verify each
ticket's linked-PR merge state directly before compiling auto-transition
candidates.

**Why:** A linked cross-system reference (PR ↔ ticket) can drift between the
subagent's check and the compile step, or the subagent's merge-check can be
incomplete — a stale "unchanged" report hides an eligible auto-transition.

**Where:** Already covered — wk-sitrep Stage 2b independently runs
`gh pr view <url> --json state,merged,mergedAt` for each In Review / Ready-for-
Review ticket, and Stage 3 end cross-validates pending spans before carry-over.
This learning is a `pattern`-type positive-steering report confirming that
mechanism fired correctly; no escalation (positive-steering exception).
