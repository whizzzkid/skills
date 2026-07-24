---
skill: wk-sharpen
date: 2026-07-24
type: gap
severity: medium
---

Step 7.5's single-pass byte budget is unhittable because the planning inputs are estimated, not
measured — the drafted addition is never byte-measured before staging.

**What happened:** Pre-draft measure of the staged body was run correctly with the hook's `measure()`
verbatim: body near ceiling, headroom ~560 B. Headroom was under 2x the intended edit, so reclaim
targets were selected up front as the rule requires, and candidate blocks were byte-measured with
`wc -c`. Addition and reclaims were staged together and measured ONCE. Result was still **net
positive** (+43 B) — a first-pass budget miss. Recovery followed the rule exactly (no second prose
nibble; one decisive structural move relocating an enumerated lookup catalog to `references/`),
landing net -485 B with healthy headroom.

**Root cause:** Two of the three budget inputs were estimates. The *reclaim* blocks were measured,
but (a) the drafted addition text was never byte-measured — its size was eyeballed from bullet
prose, and (b) the reclaim figures for edits that *rewrite* rather than delete (merging two bullets,
collapsing a nested list into one line) were estimated as "gross minus a guess", when only the
post-edit text reveals the true net. Estimating either side of a comparison whose margin is ~40 B
guarantees coin-flip outcomes. The skill mandates measuring the *body* before drafting but never
mandates measuring the *draft*, so an agent can follow every written instruction and still miss.

**Note — this is a repeat.** At least five prior learnings for this skill cover the same
budget/reclaim thrash (undershoot, one-pass-vs-loop, measure-once, reclaim-before-draft,
net-not-gross). Each was distilled into prose refinements of the same rule; the failure recurred
anyway. That pattern is the escalation signal: the rule does not need more words, it needs a
mechanical step. Distinguish the two halves — the *recovery* rule ("a second cycle means one
decisive structural cut, not another nibble") **worked as written** and should not be escalated; only
the *first-pass prediction* half failed.

**Suggested fix:** Make the budget arithmetic mechanical instead of predictive. Before staging,
write the drafted addition to a scratch file and byte-measure it (`LC_ALL=C wc -c`); for every
rewrite-style reclaim, measure the replacement text too and compute net as `old_bytes -
new_bytes`, never as gross minus a guess. Require the planned sum to be written down as explicit
numbers (addition, each reclaim's net, total) before any edit is applied — a budget that cannot be
stated as arithmetic has not been computed. Prefer delete-outright and relocate-large-block reclaims
over merge/collapse rewrites, whose net is small and hardest to predict.
