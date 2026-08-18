---
class: principle
source: learnings/skills/sitrep/2026-08-18_reserve-review-slots.md
date: 2026-08-18
severity: medium
---

## A parent that must spawn children cannot be allowed the last slot

The auto-review stage launched its top-level review workers up to a fixed cap. Each
review then needed mandatory nested workers of its own, but every slot in the runtime
was already held by a parent. Nothing could advance until the parents were interrupted
and the reviews re-run one at a time.

**Failure mode:** resource-starvation deadlock, not overload. Every individual actor
is behaving correctly and within its own documented cap; the cap is simply computed
against the wrong pool. It presents as a hang rather than an error, and it gets worse
the healthier the queue is — more PRs to review means more parents competing for the
slots their own children need.

**Guard:** derive top-level concurrency from the runtime limit divided by one plus the
maximum mandatory nested fan-out, read from the callee's contract rather than assumed.
Below two, serialize. Reserve before launching — mid-fleet exhaustion cannot be
resolved without destroying work already in flight.

**Generalized past the report:** the fixed cap was the visible defect, but replacing
one constant with another leaves the same class of bug one contract change away. The
rule is written against the parent/child slot relationship, so it holds for any stage
whose workers are themselves orchestrators.

**Landed in:** `references/auto-review.md` concurrency rule (the arithmetic) and
`SKILL.md` Stage 7 (the reservation principle).
