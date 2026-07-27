---
class: principle
skill: wk-sharpen
date: 2026-07-27
severity: medium
---

# The order-flipping token must outrank its peers, not merely differ in case

**Rule** — In the Source 3 two-stage-disagreement control, the flipping entry must be
uppercase-initial **and** its initial letter must sort *after* the initials of the
lowercase entries it is interleaved with. The two collations only disagree where case
ordering and alphabetical ordering pull in opposite directions.

**Diagnostic, in order** — compare the two sorted inputs *before* looking at the arms:

- Sorted inputs byte-identical → the **token** is wrong (rebuild it).
- Sorted inputs differ but arms agree → the element is **mis-sited** (see the placement
  table in [`memory-marker-diff.md`](memory-marker-diff.md)).

Identical arms alone never say which of the two it is, which is why the existing tripwire
("rebuild the control") could not be acted on.

**Why the prior wording was insufficient** — [`memory-marker-diff.md`](memory-marker-diff.md)
states the disagreement is case ("C orders an uppercase-initial name before
lowercase-initial ones, UTF-8 after") and warns mixed case is necessary but not sufficient
— but the stated insufficiency is entirely about **siting** (which stage is unpinned;
matched pair vs one-sided row). Nothing tied the flip to the token's letter *relative to
its peers*. Read as written, "add a mixed-case entry" is satisfied by a token that cannot
flip anything.

**The observed dead control** — an early-alphabet capital among lowercase peers whose
initials fell later in the alphabet sorted **first under both collations**: `C` puts it
first because uppercase precedes lowercase, and the case-insensitive collation puts it
first because its letter is alphabetically first. Both arms returned zero and the control
read live. Re-choosing the token so its letter fell *after* the peers' initials made the
sorts diverge, and the unpinned arm then emitted the expected phantom row while the pinned
arm returned zero.

**Classification** — `principle`. Generalizes to any collation-disagreement control, not
just this pipeline: the fixture must sit where the two orderings actually conflict.

**Escalation** — None. The existing rule is about siting and fired correctly on siting;
this names a second, independent property of the same fixture. Gap, not re-violation.

**Where** — `SKILL.md` → Batch Mode, folded into the existing two-stage-disagreement
sub-bullet rather than appended as a sibling. Siting and token selection are two
preconditions on one fixture; separating them recreates the failure, where satisfying one
reads as satisfying the control.

**Arithmetic for this pass** (both 2026-07-27 folds measured together, staged once):

- Additions **+392 B** — edit-anchor bullet 82 → 267 (**+185**); this rule folded into the
  two-stage bullet 274 → 481 (**+207**).
- Reclaim **−298 B**, four cut-site relocations, each landing in an already-linked curated
  reference: empty-listing rationale 386 → 284 (**−102**,
  [`skill-dir-resolution.md`](skill-dir-resolution.md)); ticket-token mechanism 337 → 246
  (**−91**, [`ticket-shaped-example-tokens.md`](ticket-shaped-example-tokens.md)); install
  `cd` rationale 332 → 284 (**−48**,
  [`step8-install-cd-repo-root.md`](step8-install-cd-repo-root.md)); drained-verdict
  mechanism 472 → 415 (**−57**, [`batch-mode-sources.md`](batch-mode-sources.md)).
- Audit cleanup **measured at 0 B**, not reserved — every cleanup item (four reference
  updates, two new records, the README `Version:` bump) lands outside the ceiling-bound
  file.
- Net **+94 B**; body 24317 → **24411** against the 24576 B ceiling, 165 B clear.
  Projection and measurement agree exactly.

**Ratio** — 298/392 = **0.76×**, below the 1.2× planning target and reported rather than
met. Every remaining candidate either nets ≤ ~6 B or carries a recorded protection:
[`commit-gate.md`](commit-gate.md) states the Step 8 gate's enumerated pass/fail checks
stay inline, and the ceiling rule itself protects a verification checklist and a rule's
verified-configuration qualifier. The binding gate (the ceiling) clears, so the hunt
stopped rather than widening into load-bearing content.

**Rejected reclaim targets (do not re-propose)** — the Step 7.5 "never reclaim a rule's
earliest statement" sub-bullet as a later duplicate of the de-bloat merging rule: the
later occurrence is nominally deletable, but it carries a nuance ("score duplicates by
reading order") the earlier statement only implies, and a cross-reference stub reclaims
~22 B for real coverage risk. The Step 8 anti-thrash bullet: a gate rule, explicitly held
inline by [`commit-gate.md`](commit-gate.md).
