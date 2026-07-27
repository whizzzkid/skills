---
class: principle
---

# A placeholder promoted into a settled section passes every consistency check

**Rule**

- For every value in a section headed settled / resolved / "pin exactly", grep the
  whole document set for that value or concept marked pending / TBD / unresolved.
  Any hit is a finding — leave the cell explicitly unresolved and name the item
  that resolves it.
- Reject a consistency assertion whose two sides trace back to the same literal.
  Require derived values stated as a derivation from the named source of truth,
  never restated as a second literal.

**Why**

- A wrong-but-internally-consistent pair is invisible to every consistency lens:
  both sides of the assertion trace to the same guess, so the check passes green
  and nothing surfaces the error. The review lenses covered internal consistency
  and unstated assumptions, but nothing forbade a settled-values section from
  absorbing a value still marked pending elsewhere in the same document set.
- Restating a derived value as a literal is what makes the self-comparison
  possible; a stated derivation cannot be self-consistent with a copy of itself.

**Where**

- `SKILL.md` → Step 3 → Lens C · Underlying Assumptions.
- `references/review-lenses.md` → Lens C probe list.
