---
class: principle
skill: wk-sharpen
date: 2026-07-27
severity: medium
---

**Rule** — A verification discipline attached to one *named* scan does not travel to a
sibling scan of the same construction, even inside the same step. State the verdict
protocol as a property of **any** hand-rolled scan the skill runs: one quoted path per
grep invocation via a read loop, and a verdict that branches on that scan's own rc. A
printed banner is a decoration, never a verdict.

**Why** — Step 5 runs two hand-rolled scans: the staged **path** scan and the **overfit
category** scan over drafted edit text. Only the first was covered. Running the category
scan over a space-joined path list in one quoted argument, grep received a single
nonexistent filename, returned rc=2 on every category, and the wrapper's unconditional
`echo "(none above = clean)"` reported five categories clean having read nothing. The
error text happened to be visible in the same output block — the only reason it was
caught.

**Verified against source** — Reproduced, then the reported mechanism was *sharpened*
(Step 1: a reproduction that sharpens the report voids the draft — re-derive from the
source's semantics):

- **Config A** — five paths space-joined into one quoted argument: rc=2 on all five
  categories, banner printed "clean", two genuine hits never read.
- **Config B** (the fixture varied, per Step 1) — a well-formed list containing one stale
  path: the report predicted rc=1. **Disproved.** On both BSD grep 2.6.0-FreeBSD and GNU
  grep, an unreadable path returns **rc=2 for the whole invocation even when another file
  matched** — rc=0 is masked by rc=2 while the matching line still prints.
- Consequence: `rc>=2` cannot be glossed as "never read it", and "did it print anything?"
  is no substitute for a status check. A multi-path rc is not attributable to any file.
- The read-loop form surfaced both real hits and distinguished a verified-clean category
  from a failed scan.

**Corrected documented cause** — `staged-path-scan.md` previously read `rc>=2 is "never
read it"`. The source disproves it; replaced with "at least one path was not read", plus
the domination property and the per-invocation read loop.

**Rejected suggestion** — none of substance. The report's suggested fix (state the
protocol once inside the staged-path-scan reference, both Step 5 bullets inheriting it)
was adopted; only its rc=1 claim was corrected as above.

**Rejected reclaim targets (do not re-propose, grounds stated)** —
- The Step 5 `**CRITICAL**` bullet's "Same flags ≠ same engine; the governing risk is the
  false-*clean*" clause: [`2026-07-25_same-flags-not-same-engine.md`](2026-07-25_same-flags-not-same-engine.md)
  records that mechanism as the *deliberately chosen* justification, selected because the
  source can demonstrate it. Grounds hold under every edit shape.
- The ticket-shape row and other Step 5 procedure rows: `overfit-categories.md` records
  inline placement as a deliberate decision.
- The drained-verdict canary sentence and the two-stage-disagreement control: verification
  procedures, protected by the ceiling rule ("never relocate a verification checklist
  behind a pointer"). A reader of `SKILL.md` alone would know a control is required but
  not how to build one.
- The Step 7.5 rejection-note-expiry enumeration: landed one commit earlier and is what
  drove this run to correctly re-test an *aggregate* pool-exhaustion note. Positive
  steering evidence — do not reclaim.
- The prior run's aggregate note ("every remaining candidate nets ≤ ~6 B or carries a
  recorded protection") was **re-tested, not obeyed** — aggregate grounds score no
  individual target.

**Budget** — baseline staged body 24452 B against the 24576 B ceiling, **124 B headroom**.
First draft netted +328 B; hunt entered in the documented order and exhausted with every
candidate vetoed or protected, so the *addition* was tightened (target 5) to a single
in-place line rewrite: 84 → 203 B, **net +119 B**. Audit cleanup **measured at 0 B** — both
items (this record and the `staged-path-scan.md` correction) land outside the
ceiling-bound file. Reclaim 0 B → ratio **0×**, below the 1.2× planning target and
reported rather than met; the binding gate (the ceiling) clears by **5 B**.

**Note for the next run** — 5 B of headroom is effectively none. The next content-adding
fold to this skill must open with a structural reclaim, or the ceiling will force a
prose-mangling cut into load-bearing text. The mechanism detail for this rule already
lives in the linked reference, so the cheap moves here are spent.

**Where** — `SKILL.md` → Step 5 mechanical overfit scan, the residual hand-roll bullet
(now naming both scans and carrying the rc/banner imperative); full protocol, the
domination property and the read-loop form in
[`staged-path-scan.md`](staged-path-scan.md).
