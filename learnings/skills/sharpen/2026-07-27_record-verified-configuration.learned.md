---
skill: wk-sharpen
date: 2026-07-27
type: gap
severity: medium
verified-against-source: yes
---

A mechanism verified under one configuration must land carrying that configuration, or it
reads unconditional and steers the next author into the case where it inverts.

**What happened:** A fold landed a control-construction rule ("make the *differing* element
the order-flipping one") after driving the comparison utility over its fixtures. The
verification was real, but every fixture held one stage of a two-stage pipeline fixed. The
rule was written with no mention of that, so it read as universal. The next run applied it to
a pipeline where the *other* stage was the unpinned one, satisfied every stated condition, and
built a dead control — the exact failure the rule exists to prevent. Driving the full
placement × unpinned-stage matrix showed the two placements are inverted: each is live for one
stage and provably dead for the other.

**Root cause:** Step 1 requires verifying the reported mechanism against the owning source and
rejects an unverified cause, but says nothing about recording the *boundary* of what the
verification covered. A run that drives an artifact over the fixtures it happened to build has
established the mechanism only for that configuration; the untested configurations are
invisible in the resulting rule, and nothing in the workflow prompts a check for a free
variable the fixtures held constant. So a correct, source-verified fold can still ship an
over-general rule — and it ships with the authority of a verified one, which is why the next
author follows it into the dead case rather than questioning it.

The de-bloat ceiling compounds this: the qualifying clause is the cheapest thing to cut when
headroom is tight, so the unconditional form is also the smallest one.

**Suggested fix:** After a reproduction confirms a mechanism, enumerate what the fixtures held
constant and either drive the varied cases or name the verified configuration in the rule
itself. Treat "my fixtures varied only one input" as a coverage gap to close before drafting,
not after. When the ceiling forces a choice, the conditional's *trigger* stays inline and the
per-case enumeration goes to the linked mechanics reference — an unconditional rule that is
wrong half the time costs more than the bytes the qualifier would have taken.
