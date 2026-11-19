---
skill: wk-sitrep
date: 2026-11-18
type: gap
severity: low
verified-against-source: n/a
---

A user-ticked span can contradict the external system; the close has no rule for recording that.

**What happened:** During a missed-end rollover the user had ticked two spans (a weekly-update submission and an interview scorecard). The owning systems still showed an empty draft and an unsubmitted draft. The close rules only say every ticked span survives into the snapshot, so the ticks were honored and the mismatch was surfaced only by an ad-hoc note.

**Root cause:** The close checklist counts ticked spans but never cross-checks them against the owning system, while the terminal-state rule says a saved draft is still owed.

**Suggested fix:** In the close checklist, after counting ticked spans, re-query the owning system for each. When it still shows a draft, honor the tick in the snapshot but add a one-line mismatch note to the snapshot and the next page's sweep notes, and never re-open the span unprompted.
