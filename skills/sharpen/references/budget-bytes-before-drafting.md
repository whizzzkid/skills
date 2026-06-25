---
class: principle
---

**Rule:** When a SKILL.md body is near the size ceiling, estimate the reclaim
before drafting the new rule — not after.

**Why:** Drafting first then guessing at a reclaim undershoots: a near-ceiling
edit plus a guessed trim still overshoots, forcing repeated measure-edit cycles.
When headroom (`ceiling − current body`) is under ~2× the drafted edit, the net
change must be planned non-positive on the first pass.

**Where:** Step 7.5, the "hard size ceilings" HARD RULE, alongside "Prefer
structural moves over prose-mangling."

**Rule (measurement):** Budget against the size hook's own algorithm, never an
ad-hoc `wc -c`.

**Why:** The two diverge by tens of bytes (body-delimiter choice + per-line
newline handling). An ad-hoc measure once read 24566 (under the 24576 ceiling)
while the hook measured 24630 — 64 over — forcing a second trim-and-recommit
cycle. Under ~100 bytes headroom the discrepancy is decisive.

**How:** Replicate `check-skill-size.sh`'s `measure()` — `LC_ALL=C awk` counting
`length($0)+1` per body line, body starting after the closing front-matter `---`,
against the staged blob (`git show :path`) — before drafting and before
committing.
