---
class: principle
---

# A len-0 needle is a harness defect, never a short cut

**Rule** — when a verification harness cuts a needle from a file's own bytes, a zero-length
result must fail outright as a harness defect. It must never be admitted under the length
guard's tolerance for a short cut.

**Why** — a zero-length needle is the one cut that *cannot* fail. `grep -qF -e ""` matches any
input, so admitting len 0 silently converts a per-item check into an unconditional pass and the
run reports a clean, unanimous green that certified nothing. The prior wording — "length-guard
both" — named the guard but not the verdict for len 0, leaving it to be read as the shortest
legal cut. That weak wording is the mechanism the defect travelled through, not an incidental
detail, which is why the fix amends the existing clause in place rather than appending a new
bullet beside it.

**Where** — `SKILL.md` → Step 1 → *HARD RULE: the report is a hypothesis* → the harness/control
bullet, at the existing `length-guard both` clause.

## Verification

Confirmed by driving the primitive: `grep -qF -e ""` returns **rc=0** against unrelated text,
where a real needle returns rc=1. In the originating incident the mutated-needle control was
the only check that fired (rc=0 where rc=1 was required); the length guard read len=0 as merely
short and passed all 18 items.

## Byte arithmetic

Ceiling-bound fold — 93 B of headroom at run start (body 24483 / 24576), measured through the
size hook's own `measure()` on a throwaway index copy (the real index is partitioned by another
run's staged fold and was never written to).

- Addition, exact old/new pair: `length-guard both.` → `length-guard both — len 0 is a defect,
  not a short needle.` = **+42 B**.
- Reclaim, same bullet: `never let a red result justify swapping the prescribed primitive` →
  `a red result never justifies swapping the prescribed primitive` = **−2 B**.
- Measured audit-cleanup allowance: **0 B** — the fold introduced no contradiction and the
  audit surfaced no cleanup item, matching the last two runs that priced one.
- **Net +40 B.** Body 24483 → 24523, verified by re-running `measure()`. Ceiling clear by 53 B.

The binding gate's *net non-positive* target was **unreachable** and is reported rather than
forced. Six shorter phrasings were priced (net +63 to +76 before reclaim); the one landed is the
cheapest that still states both the verdict and what it replaces. Reaching net 0 would have
required ~21 B of further reclaim, available only by re-opening a recorded rejection or by
mangling load-bearing prose in the same bullet — both forbidden by the "never widen the hunt
into load-bearing content" clause. A high-severity MUST-FOLD outranks the ceiling target where
the ceiling itself is still clear.

**Rejected drafts (do not re-propose)** — Variants carrying the rationale inline
(`(an empty needle matches everything → unanimous false OK)`, +97 to +107 B) were cut: the
failure mechanism is rationale, which belongs in this record at zero ceiling cost, and none
could approach net non-positive. A variant grafting the rule onto the adjacent
`indicts the harness` clause priced ~18 B cheaper but was rejected on **semantics**: that clause
governs how to read a *red* result, whereas a len-0 needle produces a *green* — attaching it
there would file the rule under the wrong failure polarity. A `harness defect` wording (+8 B
over the landed one) was dropped because "harness" is already established earlier in the same
bullet, so "a defect" reads unambiguously in context.

**Rejected reclaim targets (do not re-propose)** — None newly proposed. The category-1 pool (an
inline rule ending in a `references/…` pointer whose linked reference states it in full) was
re-checked against the recorded inventory and remains exhausted; every remaining candidate
carries a prior stay-inline or rejected-relocation note, and all were honored rather than
re-opened. Two in-bullet prose tightenings were priced and **dropped as meaning-losing**:
`reproduce the failure where cheap` → `reproduce it where cheap` (−10 B) makes "it" ambiguous
with the preceding "its source", and `Drive it directly` → `Drive it` (−9 B) deletes
*directly*, which is load-bearing — it distinguishes driving the artifact itself from driving
it through the harness.
