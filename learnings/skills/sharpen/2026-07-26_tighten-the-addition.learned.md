---
skill: wk-sharpen
date: 2026-07-26
type: gap
severity: medium
verified-against-source: yes
---

When the reclaim pool is exhausted, the **addition** is still a reclaim target — the budget
rules name only "report the arithmetic" or "widen the hunt", never "tighten the fold".

**What happened:** A fold into a ceiling-bound `SKILL.md` (body 24463 B of 24576, so 113 B
headroom) drafted at +487 B net. Reclaim was capped at one legitimate target worth −126 B:
every other candidate was protected by a recorded stay-inline / rejected-relocation note or
by the earliest-statement rule. The ≥1.2x planning ratio was unreachable and net stayed
positive (+361 B), which the binding gate ("net non-positive AND under every ceiling")
rejects. Read literally, the rules offered only two exits — report and stop without folding,
or widen the hunt into load-bearing content, which they also forbid.

The fold landed by shrinking the *addition* instead: 605 B -> 242 B, taking net to **-2 B**.
Two cuts did it, both content-preserving rather than prose-mangling:

- A sub-bullet that restated a rule stated in the immediately adjacent bullet was deleted
  outright (the skill already says "state a rule once; cross-reference instead of restating").
- The new rule's enumerated illustrative examples were routed to the already-linked
  `references/` file rather than placed inline — the documented split puts imperatives in
  `SKILL.md` and procedure/examples in the reference, and the reference carries no ceiling,
  so those bytes cost zero.

**Root cause:** The byte-budget rules treat the addition as a fixed input and reclaim as the
only free variable. Every lever they name points at the target file's existing content
(search duplicates, relocate, prose-tighten), and the escape hatch when those are exhausted
is framed purely as reporting. But a first draft is not a fixed quantity: it routinely
carries restatement of adjacent rules and inline examples that belong behind an existing
pointer, and both are removable at zero coverage cost. Because the rules never say so, a run
facing an exhausted reclaim pool reads its own draft as immovable and concludes the fold is
unlandable — the same standoff the measured-allowance rule was just added to dissolve, one
step further along.

**Suggested fix:** In the Step 7.5 budget rules, add the addition to the reclaim search
before declaring the ratio unreachable: audit the draft for (a) clauses restating a rule
already stated nearby, and (b) enumerated examples or failure-mode rationale that belong in
an already-linked reference. State that a draft's first size is an estimate, not a
requirement, and that tightening it is preferred over both stopping and widening the hunt —
it is the only lever that cannot endanger existing load-bearing content. Keep the existing
prohibition on dropping a rule, an error code, or a failure mode: this trims restatement and
relocates examples, never coverage.
