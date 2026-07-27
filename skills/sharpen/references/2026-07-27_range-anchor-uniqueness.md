---
class: principle
---

# A range probe's anchor must be proven unique before its count is trusted

**Rule** — The Step 7 recount guard now bounds the probe's *extent*, not only its
shape and liveness: prove a range probe's anchor unique before trusting the count,
and treat an over-count as a probe defect equal to a zero. Full procedure and
failure modes → [`recount-probe-bounds.md`](recount-probe-bounds.md).

**Why** — The existing rule guarded shape ("shape the probe to the source markup")
and liveness ("prove it fires on a known member"), and named a zero as its only
failure signal. Both guards are one-directional. A live, correctly-shaped probe
whose range is unbounded over-reports, and nothing bounded what it consumed. The
member control actively reassures: a member printed from inside the intended
section is indistinguishable from one printed by a probe that also spans the
sections after it, so the tripwire passes while the number is wrong.

**Verified against source** — Confirmed before drafting. The recount bullet stated
shape, liveness and the `→ 0 = phantom drift` signal, with no provision bounding
the range; the reporting run drove both probe forms over the same file and got 17
against a documented 5, then the correct 5 and 7 once the occurrence was selected
explicitly. The rule was exercised on this run's own drift check: the ladder's
anchor was shown unique (one `# ` heading), all 8 rungs printed and confirmed
in-section, matching the documented "8-rung".

**Escalation** — None. This is a missing direction in an existing guard, not a
repeat of a rule that already covered the case.

**Arithmetic for this fold** — Addition: recount bullet 164 B → 378 B, net
**+214 B**. Reclaim **−263 B** across two target-1 duplicates (an inline rule
whose *linked* reference states it in full):

- The Step 7.5 "Only a ceiling blocks / net non-positive is owed only when that
  trigger fires / 1.2× is the planning target" bullet (**−222 B**) —
  [`byte-budget.md`](byte-budget.md) states all three in full and more precisely,
  and its pointer already sits earlier in the same section, so nothing moves later
  in reading order. The threshold's own trigger survives inline on the
  "Measure the staged body BEFORE drafting" bullet, so the remaining text stays
  conditional rather than reading as universal.
- "Record the bump in the reference file." (**−41 B**) —
  [`escalation-ladder.md`](escalation-ladder.md) states it ("never escalate without
  recording the bump in the reference file") and its pointer is on the immediately
  preceding line.

Measured audit-cleanup allowance **0 B**: every cleanup item landed outside the
ceiling-bound file. Predicted net **−49 B**, measured body 24317 B against a
24366 B baseline — the two agree exactly. Ratio 263/214 = **1.22×**.

**Rejected reclaim targets (do not re-propose)** — The `**CRITICAL —** state the
budget as arithmetic` and `**Very important —** measure exactly once` bullets: both
are duplicated in [`byte-budget.md`](byte-budget.md), but each carries an
escalation label recording a prior re-violation, and cutting an escalated rule
discards that history. The four size ceilings enumerated at Step 7.5 remain
protected as a gate's enumerated pass/fail checks.

**Where** — `SKILL.md` → Step 7 → *Drift check* → recount bullet.
