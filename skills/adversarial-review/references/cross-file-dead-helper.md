---
class: principle
---

# Deleting a caller can strand a helper in another file (sweep 2.17 inverse)

**Rule** — When a diff deletes a private/internal helper or its only call site
(especially a consolidation collapsing bespoke helpers into a shared one), walk
one hop: from each deleted call site into the callee's own definition file, then
grep the WHOLE repo for that method's remaining callers. A helper dropping to
zero non-test callers anywhere is a blocker — remove it (and its orphaned spec)
or restore the caller. (Sweep 2.78.)

**Why** — Sweep 2.17 run forward-only (grep the definition for each kept/added
call, inside the touched file) catches dangling references but misses the
inverse, cross-file case: the newly dead method lives entirely outside the diff's
files and is reachable only from its own unit spec, so a same-file check passes
clean while dead code ships.

**Where** — `wk-adversarial-review` sweep catalog →
`references/sweep-catalog-extended.md` row 2.78.
