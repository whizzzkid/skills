---
skill: wk-sharpen
date: 2026-07-29
type: gap
severity: medium
verified-against-source: yes
---

Batch mode prescribes severity-ordered processing but no tie-break within a severity, so
each concurrent cycle picks its item by a rule it invents.

**What happened:** A batch cycle instructed to process exactly one item re-listed the queue
and found 16 unprocessed learnings — 12 of them `medium`, 3 `low`, none `high`. Source 2's
only ordering instruction is "process every unprocessed learning one-by-one,
severity-ordered", which fully determines the *band* to draw from and nothing inside it. The
run chose oldest-mtime-first (FIFO) and said so, but that choice came from the run, not the
skill. Any other cycle drawing from the same 12-wide band could equally defensibly pick the
newest, the one whose target skill it had already read, or the smallest.

**Root cause:** Confirmed against the owning text. `severity-ordered` is a partial order over
a queue that is routinely dominated by a single severity — `medium` is the default a
reporting skill assigns, so the modal queue state is one wide band, precisely the case the
ordering rule does not resolve. The gap compounds against the claim rules the same section
invests in heavily: those rules detect a peer via mtime and vanished-item checks, but they
presume the runs are *trying* to reach for different items. Two cycles applying different
self-invented tie-breaks to one band are as likely to collide on the same file as to spread
across the queue, and nothing about the collision is visible until one run's rename lands.
An undefined tie-break also makes drain order unreproducible, so a queue that stalls on a
hard item can be walked past indefinitely by cycles that each prefer something else.

**Suggested fix:** State the intra-severity tie-break in the same breath as
`severity-ordered` — oldest mtime first is the natural choice, since it bounds how long any
item can be skipped and is the only key every cycle can read without coordination. Note
explicitly that a wide single-severity band is the *expected* queue shape, not an edge case,
so the tie-break is load-bearing rather than a formality.
