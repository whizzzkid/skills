---
class: principle
---

# Published statistics pass a meaning check

**Rule** — Before shipping a data artifact, write each statistic's population and denominator in one sentence, then
test it against domain priors:

- Cumulative shares never fall as the window widens.
- Shares of one population sum to ~100%.
- A hard cutoff or an event cycle (events arriving just after a fixed interval) cannot manufacture a zero.
- Prefer full-follow-up cohorts with a complete outcome breakdown (moved on / left / other / still in state) over a
  share computed on a partial population — dropping censored or exited members inflates the share.
- One definition per concept ("typical", the outcome event, the denominator) across every view.
- Recompute every figure independently before showing the user.

**Why** — Verification that checks rendering and privacy passes while the numbers are nonsense to any domain reader:
a share over ongoing and finished stints reads as an outcome rate, a strict cutoff shows 0% where events land just
past it, a partial-population bar overstates a near-universal step, and drifting definitions contradict across tabs.

**Where** — `SKILL.md` → Phase 3: Test → verification bullets.
