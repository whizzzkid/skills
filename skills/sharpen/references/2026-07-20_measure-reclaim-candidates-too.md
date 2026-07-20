---
class: principle
---

**Rule** — Stage the addition AND the chosen reclaim cuts together, then run the
hook's `measure()` ONCE. Never estimate reclaim savings by eye — a prose reclaim's
byte delta is as unpredictable as an addition's.

**Why** — "Measure before drafting" covered the addition but not the reclaim side.
Eyeballing reclaim savings ("~120 B") overshoots repeatedly and reproduces the
measure-and-trim loop from the other direction. If the single combined
measurement is still over, that is the re-plan signal → one larger structural
cut, not another estimated prose trim.

**Where** — Step 7.5 de-bloat gate, "measure exactly once" sub-bullet.
