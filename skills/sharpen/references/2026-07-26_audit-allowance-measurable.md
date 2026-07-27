---
class: principle
---

# The audit-cleanup allowance is measurable, not a fixed reserve

**Rule** — The ~25%/floor-300 B audit-cleanup allowance is an estimate standing in for
cleanup bytes *not yet measured*. Run the Step 5 audit before the byte budget locks and the
allowance becomes a measurement: count only the cleanup bytes that land **inside the
ceiling-bound `SKILL.md`**. The measurement **replaces** the estimate — it never adds to it.
Cleanup landing anywhere else costs zero, so a measured allowance is frequently **0 B**.

**Why** — The allowance exists because Step 5 cleanup is normally *discovered after* the
budget locks, and that ordering guarantees an overrun rather than merely permitting it. But
the ordering is a **default, not a constraint**: nothing prevents running the audit first, and
at that point the allowance stops being an estimate. Read as an unconditional reserve, the
rule manufactures a standoff under tight headroom — fold plus reserve exceeds headroom while
the reclaim pool is exhausted and every remaining target is load-bearing — whose only exits
are "don't fold" or widening the hunt into protected content. Measuring dissolves it, because
per-learning records, linked `references/` files, newly created references, and a sibling
`README.md` `Version:` bump carry no ceiling at all.

**Verified against source** — The claim was checked against the owning text before drafting,
then demonstrated on this run:

- `SKILL.md` Step 7.5 stated the allowance unconditionally, and the linked
  [`byte-budget.md`](byte-budget.md) grounded its rationale purely in ordering ("those bytes
  are *discovered* after the budget locks"). Neither carried any provision for an audit
  already run, nor any distinction between in-file and out-of-file cleanup bytes. Gap confirmed.
- The size hook's `measure()` was driven **verbatim** through a throwaway index copy (the real
  index held another fold's staged paths), pre-edit: body **24463 B** against a 24576 B
  ceiling — **113 B** headroom.
- The audit was then run *before* locking the budget. All four cleanup items landed outside
  the ceiling-bound file: this reference, the `byte-budget.md` rewrite, the README `Version:`
  bump, and no in-`SKILL.md` contradiction to repair. **Measured allowance: 0 B, not 300 B.**

**Arithmetic for this fold** — Addition **+124 B** (Step 7.5 allowance bullet rewritten).
Reclaim **−126 B**: the Source 3 unanimity bullet's rationale clause ("a shape-partial matcher
splits by construction, so a mixed verdict is a blind spot's signature, not evidence against
one"), which the *linked* [`memory-marker-diff.md`](memory-marker-diff.md) states in full, and
whose pointer sits on the immediately following line — so the cut moves nothing later in
reading order. Measured allowance **0 B**. Net **−2 B**.

The ≥1.2× planning ratio was **unreachable** (126/124 = 1.02×): category-1 and category-2
targets are exhausted, and every remaining candidate carries a recorded stay-inline or
rejected-relocation note. Rather than widen the hunt, the *addition* was tightened until net
went non-positive. The binding gate — net non-positive and every ceiling clear — is met.

**Rejected drafts (do not re-propose)** — A three-sub-bullet version (+487 B) was cut: its
"beats widening the reclaim hunt into load-bearing content" clause restates the adjacent
binding-gate bullet, and its enumerated list of zero-ceiling artifacts belongs in the linked
reference, not inline. A 222 B variant naming "before the budget locks" was rejected in favour
of the 242 B one despite being 20 B cheaper — it drops "only ceiling-bound-file bytes count",
leaving "often 0 B" an unexplained assertion. The precise "before the budget locks" ordering
lives in [`byte-budget.md`](byte-budget.md) instead, at zero ceiling cost.

**Rejected reclaim targets (do not re-propose)** — The four size ceilings enumerated inline at
Step 7.5: they are a gate's enumerated pass/fail checks, protected even though
[`byte-budget.md`](byte-budget.md) tabulates them in full. The batch-mode
"control must reproduce the *disagreement*" bullet: its full statement in
[`memory-marker-diff.md`](memory-marker-diff.md) is reachable only via a pointer that appears
*later* in the body, so cutting it would move the rule later in reading order.

**Where** — `SKILL.md` → Step 7.5 (allowance bullet) and Source 3 (unanimity bullet, rationale
reclaimed); full mechanics in [`byte-budget.md`](byte-budget.md).
