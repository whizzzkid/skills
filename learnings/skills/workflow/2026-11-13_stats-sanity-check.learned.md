---
skill: wk-workflow
date: 2026-11-13
type: correction
severity: high
verified-against-source: n/a
---

Published statistics on a data-viz page without sanity-checking them against domain priors.

**What happened:** A state-progression data page shipped stats the user repeatedly caught as nonsensical:
a share computed over all stints (including ongoing ones) read as an outcome rate; a cumulative-incidence curve
with a strict one-interval cutoff showed a 0% outcome rate within that interval because events arrive in fixed
cycles just after it; an "outcome within N intervals" bar hid exited and still-in-state members, so a step nearly
everyone passes read well short of universal; three different "typical time" definitions contradicted each other
across tabs.

**Root cause:** Verification checked rendering and privacy, not meaning. No step compared each number to what a
domain reader already knows, and definitions (the outcome event, "typical", denominators) drifted between views.

**Suggested fix:** Add to the data-artifact test phase: before publishing, (1) list each statistic with its
population and denominator in one sentence; (2) check priors — cumulative shares never fall as windows widen,
shares of one population sum to ~100, event timing (cycles, cutoffs) can't produce artificial zeros, entry-state
stays are short; (3) prefer full-follow-up cohorts with a complete outcome breakdown (moved on / left / other /
still here) over partial-population shares; (4) use one definition per concept across all views; (5) run an
independent recompute-and-sanity audit before showing the user.
