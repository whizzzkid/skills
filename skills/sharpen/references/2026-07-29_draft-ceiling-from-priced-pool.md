---
class: principle
---

# Price the reclaim pool with headroom, so the draft has a ceiling instead of a verdict

**Rule** — Price the reclaim pool at the **same measure as headroom**, before drafting, and
invert both thresholds into a single ceiling on the draft:
`draft_max = max(headroom/2, pool_NET/1.2)`. Draft to that number.

**Why** — Both existing thresholds are stated *relative to the edit* (`~2×` trigger,
`≥1.2×` ratio), so neither can be evaluated until the edit's size exists. Sequenced
`measure headroom → draft → price pool → net`, the pool arrives too late to shape anything
and can only return a verdict on a size already fixed; the sole remaining lever is trimming
what was just written. The ordering *guarantees* the measure-and-trim cycle the skill
elsewhere flags as a re-violation signal, rather than merely permitting it. Inverted, the
same two numbers become a target the first draft can be written against.

**Verified against source** — Confirmed before drafting, not taken from the report:

- The reported circularity is real in the owning text: the trigger's antecedent
  ("headroom under ~2× **the edit**") and the pool requirement ("combined NET exceeds
  **the edit** by ≥1.2×") both take the edit as an input, while the bullet's own imperative
  orders the measure *before* the edit exists. "Budget ≥2 reclaim targets up front" fixes
  the pool's *cardinality* up front but its *size test* only against a known edit.
- Every prior record on this cohort prices the pool against a drafted edit and none
  inverts the dependency — the reclaim-must-exceed, budget-margin, and measure-once records
  all read "reclaim vs the drafted rule". So this is a placement gap, not a repeat.

**Rejected suggested fix (do not re-propose)** — the report's
`draft_max = (headroom + priced_reclaim) / 1.2`. It folds the ceiling constraint into the
ratio, and the two are different tests. Applied to the reported incident it yields
`(195 + 574)/1.2 ≈ 640 B` and blesses a 597 B addition whose real pool ratio is
`574/597 = 0.96×` — below the `1.2×` target the formula claims to enforce. Headroom is not
part of the ratio. The blocking condition the report was reaching for is
`addition − pool_NET ≤ headroom`, which is strictly looser than `pool_NET/1.2` whenever the
trigger fires (`0.833·pool ≤ pool + headroom` always), so it never binds and does not
belong in the derived ceiling.

**Audit — a contradiction this fold had to resolve.** "A second measure-and-trim cycle is
the re-violation signal" read unscoped forbids exactly what search target 5 ("tighten the
addition"; "a draft's size is an estimate, not a requirement") sanctions. Scoped the bullet
to the **staged** measure: pre-draft iteration against a derived `draft_max` asserts no
measurement and re-litigates nothing, so it is the discipline working. Landed in the linked
reference, which carries zero ceiling cost.

**Escalation — none.** No installed rule names the pool-before-draft ordering or a draft
ceiling, so nothing failed to steer; this is a gap in placement. The re-measure rule the
reported run *did* obey is conceded as correct in the learning itself — positive-steering
evidence, which blocks a notch.

**Arithmetic (fold applied under its own new rule)** — Staged body measured pre-draft at
**24197 / 24576 B → headroom 379 B**. Reclaim pool priced at the same measure: only two
category-1/2 candidates survived the recorded-note re-test (a trailing rationale clause and
a parenthetical, ~69 B combined), so `pool_NET/1.2 ≈ 57 B` and `headroom/2 = 189 B` →
**`draft_max = 189 B`**. Drafted to that number: single-line rewrite, old **192 B** sliced
from the file, new **364 B**, **net +172 B**. Trigger silent (`379 ≥ 2 × 172`), so no
reclaim was owed and the priced pool went unspent. Measured audit allowance **0 B** — the
Step 5 cleanup landed in a linked reference, this record, and a `README.md` `Version:` bump,
all outside the ceiling-bound file. Post-fold body **24369 B**. Two pre-staging draft
revisions occurred against the derived ceiling, each re-measured; zero staged trim cycles.

**Classification** — `principle`. Generalizes to any budget whose threshold is expressed
relative to a quantity the same procedure has not yet chosen: invert the threshold into a
ceiling on that quantity and decide it once, rather than deriving it and then judging it.

**Where** — `SKILL.md` → Step 7.5, the "Measure the staged body" bullet; mechanics and the
rejected formula in [`byte-budget.md`](byte-budget.md), new "Deriving the draft's ceiling
before drafting" section.
