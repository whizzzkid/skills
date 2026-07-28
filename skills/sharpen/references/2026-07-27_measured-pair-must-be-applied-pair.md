---
class: principle
date: 2026-07-27
severity: medium
---

# Revising the addition after measuring voids the measurement

**Rule** — `SKILL.md` Step 7.5: "Revising either side after measuring voids it —
re-measure." Full failure mode and the rationalization to reject:
[`byte-budget.md`](byte-budget.md) → *Stating the budget as arithmetic*.

**Why** — Not a re-violation of "the priced pair must BE the applied pair". That rule
targets **retyping** a pair instead of slicing it, and it was obeyed: the pair was sliced,
priced, and the projection was correct at the moment it was made. The gap is **temporal** —
the addition was trimmed *afterward* to lift the reclaim ratio over its planning target,
and the trimmed variant, never measured, is what landed. The recorded arithmetic was wrong
by 20 B until post-staging measurement contradicted it.

Nothing in the sequence re-asserted the binding between measured text and applied text,
and a late trim does not present as an event that invalidates a measurement — it only ever
removes bytes, so it feels like a strict improvement. The classification is therefore
`partial`, not `already-covered`: the installed rule's clause is intact and a new clause
covers the uncovered half.

## Applied to this fold

Step 4's gate rule ("edit target governs this fold's own landing → apply the stricter of
pre-edit and post-edit text") binds here, since the edited rule is the one budgeting this
very edit. The **post-edit** text is stricter, so it was applied: the addition was
re-measured after each of the tightenings this run made, and the staged `measure()` was
re-run rather than a transcript number reused.

## Same-pass reclaim

Headroom was 119 B. The full failure-mode text went to `byte-budget.md`, which costs zero
ceiling bytes and is where the split-by-design already puts procedure and failure modes —
`SKILL.md` keeps only the imperative (+66 B). Reclaimed 129 B by deleting the sub-bullet
"Never reclaim a rule's earliest statement", a verbatim restatement of the de-bloat rule
"Merging duplicates → keep the occurrence a run reaches first", which a run reaches ~10
lines earlier. Deleting the *later* occurrence is what that rule itself prescribes. Net
**−63 B** (24457 → 24394).

**Where** — `SKILL.md` → Step 7.5, the CRITICAL budget-arithmetic bullet.
