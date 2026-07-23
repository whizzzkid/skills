---
class: principle
---

- **Rule:** In the de-bloat measure-once budget, count a reclaim by its NET byte
  drop, not gross. A prose-block relocation to `references/` reclaims gross MINUS
  the inline stub it leaves behind (heading + pointer + any retained trigger
  sentence); for a short block the stub dominates, so prefer relocating a LARGE
  block or deleting a provably-duplicated rule outright (no stub) to fund a
  modest addition. Budget the >=1.2x margin against the NET figure.
- **Why:** Folding a rule into a SKILL.md sitting a few bytes under the body
  ceiling, the relocated block's replacement stub ate roughly half its gross, so
  the single staged measure came out over ceiling despite a reclaim that looked
  large enough. "Combined size" in the measure guidance reads as gross unless the
  stub subtraction is stated.
- **Where:** Step 7.5 de-bloat "content-removing structural moves" and
  "measure-once" bullets.
