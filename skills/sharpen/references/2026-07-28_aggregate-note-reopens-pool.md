---
class: principle
---

# An aggregate pool-exhaustion note reopens under per-candidate re-scoring

**Rule** — Already covered. No `SKILL.md` change. The reported behavior is the rule
working, not failing.

**Verified against source** — The report's own "nothing to change" claim was checked
against the owning text before accepting it, and every asserted rule was located:

- Step 7.5 reclaim search: *"Grep `references/` for a recorded stay-inline /
  rejected-relocation note before relocating — a hit vetoes only while its stated grounds
  still hold."*
- The immediately following bullet: *"Grounds unstated, aggregate, or scored before a
  now-reachable shape → re-test, never obey."* This is the report's conditional fix
  ("treat any note lacking a per-candidate score as absent rather than as a veto") stated
  verbatim, and it already applies retroactively — it tests the note, not the note's date.
- Linked [`byte-budget.md`](byte-budget.md), "A rejection note is a verdict under an edit
  shape": *"**Grounds aggregate** — 'every remaining candidate carries a recorded note'
  scores no individual target. It is a pool summary, never a per-candidate veto."*
- Same reference, the note-authoring requirement: *"Write every stay-inline,
  rejected-relocation, or pool-exhaustion note so it names the edit shape it was scored
  under, and score candidates individually."*
- The report's "reads like a completed search" rationale is the same insight the linked
  reference already carries: *"the note reads identically before and after. Treated as a
  fact about the target, every historical rejection hardens into a permanent veto."*

Coverage matches at the **rule** level, not merely the topic level, on every point the
report raises. Classified `already-covered`, not `partial`.

**Escalation — none; positive-steering evidence.** The reported run *consulted* the grep
rule, hit the aggregate note, applied the re-test bullet, and reopened two candidates the
note had written off — landing the fold at a 1.21× ratio without touching load-bearing
content. The learning concedes this directly ("the aggregate-grounds rule and the search
order both fired correctly once consulted"), which is the exception the escalation rule
names. A repeat that the rule *prevented* is evidence of steering, never of a notch owed.

**Audit — the amend-in-place obligation is already discharged.** Two checks, both clean:

- The aggregate note that misled the earlier passes carries an in-place amendment
  restating it as a pool summary and pointing at the shape-contingency rule. Nothing left
  stale.
- The reopening pass recorded its own rejected relocations **individually, with stated
  grounds and the shape each was scored under**, marking one explicitly retirable if its
  clause ever lands in a linked reference. That is the note-authoring rule satisfied, so
  the pool this pass closed will reopen correctly rather than hardening.

**Why this is worth a record at all** — Three passes now trace to one aggregate note: two
walked past a live pool before the re-test rule existed, one reopened it after. Filing the
success keeps the next pass from reading the surviving note as fresh evidence of
exhaustion and re-deriving the whole history. The standing trigger for reinforcement is
unmet and stated here so a later pass can test it directly: reinforce only if a pass again
reaches the tighten-the-addition fallback **with an aggregate note as its stated reason**.

**Classification** — `principle`. Generalizes to any durable-record-plus-gate pairing where
a summary verdict is consulted by a later pass that cannot see whether individual
candidates were ever scored. Already discharged in this skill; recorded so the coverage is
citable without re-reading the incident.

**Where** — `SKILL.md` → Step 7.5, size-ceiling reclaim search (unchanged); mechanics in
[`byte-budget.md`](byte-budget.md).
