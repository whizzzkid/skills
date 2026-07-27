---
class: principle
---

# Zero-risk reclaim hides under an existing `references/…` pointer

**Gap** — Step 7.5 and `byte-budget.md` explained how to *count* a duplicated rule
("deleting a provably-duplicated rule nets its full size") but never where to find one.
Nothing ordered the search, so a de-bloat pass under ceiling pressure went looking in the
wrong places: prose-tightening candidates yielded a fraction of the needed bytes and the
hunt drifted toward relocating load-bearing procedure. The reclaim that actually worked
came from a different move entirely — opening the reference a nearby inline bullet already
pointed at and finding the bullet's trailing rule stated there verbatim, making the inline
clause deletable at full value with zero replacement.

**Verified against source** — Confirmed both halves before drafting:

- The reference's "Choosing reclaim targets" section carried the counting rule and no
  locating rule.
- Recorded stay-inline decisions *do* exist across the reference set, and nothing in the
  skill or the reference directed a run to check them before proposing a relocation.

**Principle** — A pointer is evidence that a fuller statement exists elsewhere, so an
inline rule ending in one is the prime duplicate candidate and the cheapest to prove.
Where a reference declares that the imperatives live in the skill body while it carries
the procedure and failure modes, any failure-mode rationale left inline under that pointer
is duplicated *by construction* — a structural pool, not a lucky find.

**Scope limit distilled alongside it** — Only a *linked* reference proves coverage. A
per-learning distillation record is never linked from `SKILL.md`, so text surviving only
there is absent at runtime; deleting an inline rule against one silently drops it.

**Where** — `SKILL.md` → Step 7.5, spliced into the content-removing-structural-moves
bullet as an ordered search (duplicates first, relocate last, prose-tighten only for the
final margin) plus the stay-inline-note check. Full ordered procedure, the linked-only
caveat, and the reopen-explicitly rule → `byte-budget.md` "Where to look, in order".

**Escalation** — None. The one part of this learning that repeated an existing rule (the
unreachable 1.2× ratio) carried positive-steering evidence: the reporting run met the
binding gate and explicitly did *not* chase the ratio, so the rule fired correctly.
Instead of escalating, the existing bullet's antecedent was widened from the single
"cleanup overrun" case to any unreachable ratio, since an already-de-bloated skill holding
no more zero-risk targets reaches the same state by a different route.

**Rejected suggestion (do not re-propose)** — Did not relocate the throwaway-index command
fence or the overfit-scan stay-inline procedure rows to buy back bytes; both carry recorded
stay-inline decisions, and honoring them was the check this fold exists to add. Did not
chase the 1.2× planning ratio against fold-plus-allowance once the binding gate (net
non-positive, every ceiling clear) was met — widening the hunt at that point only
endangers load-bearing rules.

**Arithmetic for this fold** — Reclaim 401 B across four inline clauses their linked
reference states in full, all four located by applying this fold's own rule to itself;
against a fold that grew to ~369 B once Step 5 cleanup split an over-chained bullet, for a
final body of 23557 B and net **−32 B**.

**What the run itself re-proved** — The first draft (a standalone two-bullet fold, +615 B)
could not clear a non-positive net at all and had to be re-scoped: the full ordered
procedure went to the reference, leaving a short imperative inline. Later, splitting the
spliced bullet to honor one-rule-per-bullet pushed net positive (+39 B) — the documented
re-violation signal. It was discharged as prescribed, with one decisive cut rather than a
nibble hunt, and the cut came from target #1 again: the new bullet's own parenthetical
rationale, already stated in full in the reference it points at. Style compliance and the
byte gate were both satisfiable because the reclaim rule applies to the fold's own text.
