---
skill: wk-sharpen
date: 2026-07-20
type: pattern
severity: low
---

Even with "measure before drafting" in place, the reclaim loop repeated because reclaim-candidate byte sizes were eyeballed, not measured.

**What happened:** Folding a rule into an at-ceiling skill (81 B headroom). I measured the staged body first (per the existing rule), but estimated each reclaim's savings by eye ("~120 B", "~40 B"). The estimates overshot repeatedly — the body landed 116 B over, then 10 B over — forcing three measure-and-trim cycles before clearing, the exact loop the gate names.

**Root cause:** The de-bloat gate says measure the *addition* and never eyeball its char count, but says nothing about the *reclaim* side. Prose-reclaim savings are just as unpredictable as additions (a `→` is 3 B, markdown escapes vary), so estimating them by eye reproduces the same over-ceiling loop from the other direction.

**Suggested fix:** Extend the "measure exactly once" rule so BOTH sides are measured before committing to a pass: after staging the addition AND the chosen reclaim cuts together, measure once — never estimate reclaim savings by eye. If the single combined measurement is still over, that IS the re-plan signal; make one larger structural cut, do not re-estimate another prose trim.
