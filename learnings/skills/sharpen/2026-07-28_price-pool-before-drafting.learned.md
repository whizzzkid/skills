---
skill: wk-sharpen
date: 2026-07-28
type: gap
severity: medium
verified-against-source: yes
---

Measuring headroom before drafting is not enough to prevent a trim cycle — the draft needs a
byte ceiling derived from headroom **plus the priced reclaim pool**, before the first draft.

**What happened:** The run measured the staged body before drafting, exactly as Step 7.5
requires (24381 of 24576 — 195 B headroom). It then drafted the fold by *content*, producing
a 1004 B addition, and only afterwards priced the reclaim pool at 574 B. Net came out at
+430 B against 195 B of headroom, so the addition had to be tightened twice (1004 → 610 →
597 B) before the arithmetic cleared. Each revision voided the prior measurement and forced
a re-measure, which the skill correctly demands but which was avoidable work.

The byte-budget reference explicitly names a second trim cycle as a re-violation signal:
*"A second measure-and-trim cycle is the re-violation signal. Stop and re-plan with one
decisive structural cut, not another prose nibble."* This run hit exactly that signal, and
the tightening was prose-level, not structural.

**Root cause:** Confirmed against the source. Step 7.5 sequences the budget as
*measure headroom → draft → price reclaim → net*. The reclaim pool is the larger and more
constrained of the two inputs, but nothing prescribes pricing it **before** the draft exists,
so the draft is sized against content requirements rather than against a known ceiling. The
existing instruction "budget ≥2 reclaim targets up front whose combined NET exceeds the edit
by ≥1.2×" is phrased relative to *the edit* — it presumes the edit's size is already known,
which is precisely what has not been decided yet at that point. At near-zero headroom the
ordering guarantees a trim cycle rather than merely permitting one.

**Suggested fix:** Price the reclaim pool in the same step as the headroom measure, then
derive and write down an explicit draft ceiling before drafting:
`draft_max = (headroom + priced_reclaim) / 1.2`. Draft to that number. This inverts nothing
about the existing rules — it just moves the pool pricing ahead of the draft so the draft has
a target instead of a verdict. State it where the headroom measure is prescribed, since that
is the point the ordering is set.

**Note on the ratio:** the run reported 0.96× against the 1.2× planning target. With the
pool priced first, the draft ceiling would have been (195 + 574) / 1.2 ≈ 640 B, and a 597 B
first draft would have met the target on the first attempt with no trim cycle at all.
