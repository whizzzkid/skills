---
skill: wk-sharpen
date: 2026-07-27
type: correction
severity: medium
verified-against-source: yes
---

Tightening the addition *after* the budget measurement silently invalidates the arithmetic —
the measured pair must be the pair actually applied.

**What happened:** The byte budget was measured correctly as an exact old/new pair, the
projection cleared the ceiling, and the ratio was reported. Then the addition was trimmed once
more to lift the reclaim ratio over its planning target, and that trimmed variant — never
measured — is what got written to the file. The recorded arithmetic (addition, net delta,
projected body) was wrong by 20 bytes until the post-staging measurement contradicted it and it
was corrected in the distillation record.

The error was benign only by luck: the margin absorbed it. Had the trim gone the other way, or
had the margin been the 19 bytes it started at, the projection would have said "clears" while
the staged body breached the ceiling, and the discovery would have come from the hook at commit
time rather than from the plan.

**Root cause:** The installed rule already says to state the budget as arithmetic before any
edit and to byte-measure "the addition as the *exact* old/new pair you will apply". The rule was
followed at the moment of measurement and then quietly broken by a later revision. Nothing in
the sequence re-asserts the binding between the measured text and the applied text, and the
final "stage together, measure exactly once" step reads as a confirmation of a decision already
made rather than as the check that would catch a drifted pair. A last-minute tightening feels
like a strict improvement — it only ever removes bytes — so it does not present as an event that
invalidates a measurement.

**Suggested fix:** Bind the measurement to the artifact rather than to a transcript number:
measure the addition from the same buffer that will be applied, and if the text changes at all
after measuring, re-measure before editing. Treat "the trim only removes bytes, so the
projection stays safe" as the specific rationalization to reject — a projection is a claim about
a number, and an unmeasured edit makes the number unverified regardless of its sign. Direction
of change is not evidence of magnitude.
