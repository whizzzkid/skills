---
skill: wk-sharpen
date: 2026-07-25
type: gap
severity: medium
verified-against-source: yes
---

The highest-yield byte reclaim hides in an inline rule whose own linked reference already
states it in full — and a reference may carry a recorded "stay inline" decision that forbids
the relocation being considered.

**What happened:** A content-adding fold into a `SKILL.md` measuring 23594 B against a
24576 B ceiling left 982 B headroom. With the audit-cleanup allowance the budget rule
demanded ~596 B of reclaim, but prose-tightening candidates yielded only ~110 B combined,
and the search drifted toward relocating a command fence and a procedure row — both
load-bearing. The reclaim that actually worked came from a different move: an inline bullet
ended with a pointer to a curated shared reference, and opening that reference showed it
already stated the bullet's trailing rule verbatim. The inline clause was deletable at full
value with zero replacement, netting 93 B — the single largest target found.

Separately, one relocation candidate was already forbidden: a reference file closed with a
note recording that specific procedure rows "stay inline because they are procedure, not a
checklist." That note was the only thing preventing a byte-motivated move that a later pass
would have had to undo.

Final arithmetic: +197 B addition, −202 B reclaim across three targets, net −5 B, body
23589 B. The binding gate (net non-positive, every ceiling clear) was met with ~987 B of
headroom remaining; the 1.2x planning ratio was not, and was correctly not chased.

**Root cause:** Step 7.5's "Choosing reclaim targets" explains how to *count* a duplicated
rule (full size, zero replacement) but never says where to look for one. Every inline rule
that already carries a `references/…` pointer is a candidate duplicate by construction —
the pointer is the evidence that a fuller statement exists elsewhere — yet nothing directs
the search there, so the scan defaults to eyeballing prose. Symmetrically, nothing directs a
check for a recorded stay-inline decision before proposing a relocation, so the ceiling
pressure argues for a move the skill's own history already rejected. Confirmed by driving
the size hook's `measure()` verbatim against a throwaway staged index at each step.

**Suggested fix:** In Step 7.5's reclaim-target guidance, order the search: first, for each
inline rule carrying a `references/…` pointer, open that reference — if it states the rule in
full, delete the inline clause outright (full-value reclaim, zero coverage risk); only then
consider relocation, and never before grepping the reference files for a recorded stay-inline
or rejected-relocation note covering the block. Add that an unreachable 1.2x ratio at an
already de-bloated ceiling is discharged by meeting the binding gate and reporting the
arithmetic, not by widening the hunt into load-bearing content.
