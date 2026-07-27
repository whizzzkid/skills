---
class: principle
---

**Rule** — Build a positive control from a subject the pattern *matches*, never from the
pattern's own source text. Expand every metacharacter to reach a concrete literal
(`a[-_]?b` → `a-b`, drop `\b`, resolve quantifiers). When the control comes back red, it
indicts the **control** before the matcher: repair the canary and re-run before concluding
anything about the primitive, and never let a red control license swapping the primitive.
Keep the canary in memory (`printf … | grep -f`) whenever the pattern list is a denylist.

**Why** — A denylist holds regexes, so pattern text and matching text are different
strings; pasting the pattern verbatim produces a subject of literal metacharacters that the
pattern cannot match. The control then returns no match and reports "matcher is broken"
against a working matcher, leaving the real scan's `NONE` unverified and making the next
move — swap or abandon the comparison primitive — look justified by evidence that was
manufactured by the control's own construction. Driving the real denylist directly
confirmed both halves: pattern-source-as-subject does not match, the expanded literal does.
A canary is also by construction a prohibited term, so writing it to a staged path would
trip the very hook under test.

**Escalation** — This repeats the pre-existing expansion rule in
[`staged-path-scan.md`](staged-path-scan.md), which already prescribed a literal expanded
from a real non-comment denylist line. Re-violation → escalated exactly one rung, baseline
prose → `**Important:**`. No positive-steering evidence existed to block the escalation:
the run recovered only *after* the bad canary, which is self-correction, not the rule
firing.

**Classification** — `partial`. The expansion half was already covered (cited above); the
newly distilled parts are the failed-control diagnostic ordering and the in-memory
constraint.

**Rejected** — Did not relocate the ticket-shape rejection or any other "stay inline"
procedure row to reclaim bytes; `overfit-categories.md` records that inline placement as a
deliberate decision. Did not move the throwaway-index command fence behind a pointer to
reach the 1.2× planning ratio — the binding gate (net non-positive, every ceiling clear)
was already met with ~987 B of ceiling headroom left, and the ceiling never outranks a
load-bearing command.

**Where** — `SKILL.md` → Step 1 verification-tooling rule (general form, merged with the
harness-indict rule); canary-construction mechanics in
[`staged-path-scan.md`](staged-path-scan.md).
