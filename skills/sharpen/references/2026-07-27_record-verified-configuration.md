---
class: principle
---

# A verified mechanism must land carrying the configuration it was verified in

**Rule** — Reproduction establishes a mechanism only for the configuration it ran under.
Before drafting, enumerate what every fixture held **constant**; then either drive the
varied cases, or name that configuration in the rule's own trigger. The qualifier is
load-bearing text, not trim — de-bloat may never cut it to reclaim bytes.

**Why** — Step 1 already rejects an *unverified* cause, but said nothing about recording
the **boundary** of a verification that succeeded. A run that drives an artifact over
fixtures varying one input has established the mechanism only there; the pinned free
variables leave no trace in the resulting rule, so a correct, source-verified fold still
ships an over-general rule. That rule then carries the authority of a real verification,
which is precisely why the next author follows it into the case where it inverts rather
than questioning it. The size ceiling compounds the failure: a qualifying clause is the
cheapest thing to cut when headroom is tight, so the unconditional form is also the
smallest one.

**Failure mode observed** — A control-construction rule was verified over fixtures that
held one stage of a two-stage pipeline fixed, and was written without that condition. A
later run applied it to a pipeline where the *other* stage was the unpinned one, satisfied
every stated condition, and built a dead control — the exact failure the rule existed to
prevent. Driving the full placement × unpinned-stage matrix showed the two placements are
**inverted**: each is live for one stage and provably dead for the other.

**Classification** — `principle`. Generalizes to any fold whose evidence is a reproduction
over fixtures, in any skill.

**Escalation** — None. Step 1 carried no boundary-recording precondition; this is a gap,
not a re-violation of an existing rule.

**Budget** — Addition **+233 B** (Step 1 trigger clause +178, Step 7.5 protected-list
clause +55). Reclaim **−233 B**: the Step 5 throwaway-index code block relocated into the
linked [`byte-budget.md`](byte-budget.md), which already stated the procedure and its
`unset GIT_INDEX_FILE` footgun in prose (−269, +68 for a pointer placed **at the cut
site**, so reading order is unchanged); plus two filler-only rewrites in the Step 1
hypothesis bullet (−32). Measured in-`SKILL.md` audit cleanup **0 B**. Net **0** —
non-positive, body 24515/24576.

The ≥1.2× planning ratio was **unreachable** (233/233 = 1.0×), as recorded by the prior
pass: category-1 duplicate deletion is exhausted and every other candidate carries a
stay-inline or rejected-relocation note. The addition was tightened until net went
non-positive; the binding gate is met.

**Rejected reclaim targets (do not re-propose)** — The four ceilings at Step 7.5, the
batch-mode two-stage-disagreement bullet, and the ticket-shape rejection, all previously
recorded. Additionally: the Step 5 `CRITICAL` hook-vs-hand-roll rationale ("same flags ≠
same engine", the silent-`NONE` failure mode) — its full statement lives only in an
*unlinked* per-learning record, so cutting it inline would make it unreachable rather than
relocate it.

**Where** — `SKILL.md` → Step 1, verify-against-owning-source HARD RULE (trailing clause on
the deterministic-artifact bullet); protection clause at Step 7.5, reclaim-target list.
