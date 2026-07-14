---
class: principle
---

# Reclaiming bytes: delete a duplicated rule outright, never cross-ref it back

**Rule.** When the byte-reclaim target is a provably-duplicated rule, delete it
with zero replacement text. A cross-reference back ("per Hard Rule N") re-spends
most of the reclaim, because the rule is already stated at the cited location.
Budget the reclaim as the full byte count of the deleted line, not
line-minus-pointer.

**Why.** A tight-headroom fold left 29 B over; the "one decisive cut" removed a
duplicated sentence (~68 B) but added a `(per Hard Rule 7)` parenthetical (~50
B), netting only ~18 B and forcing a second corrective cycle — the re-violation
signal Step 7.5 warns against. The pointer that justified deleting the line is
the same pointer that was redundantly re-added.

**Where.** Step 7.5 content-removing-moves bullet, clause (2): "or a
provably-duplicated rule — the latter outright with zero replacement (a
cross-ref back re-spends the reclaim)."
