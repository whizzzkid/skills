---
skill: wk-sharpen
date: 2026-06-30
type: correction
severity: medium
---

Reclaim budget must be picked up front, not discovered across measure cycles

**What happened:** Folding a high-severity rule into a SKILL.md with only ~378 B
body headroom, I drafted the rule, measured the staged body, then trimmed prose
and re-measured, then trimmed once more and measured a third time before net
change crossed non-positive. Three measure-and-trim cycles for one fold.

**Root cause:** I did not budget the reclaim before drafting. The de-bloat rule
already says: when headroom < ~2× the drafted edit, measure the staged rule once
and pick reclaim target(s) whose combined size exceeds it with ≥1.2× margin
(≥2 targets) — then apply in ONE pass. A second measure-and-trim cycle is itself
the re-violation signal. I treated reclaim as iterative nibbling instead.

**Suggested fix:** Reinforce that the reclaim set is chosen BEFORE drafting when
headroom is tight: list ≥2 concrete reclaim targets totalling ≥1.2× the expected
edit, apply all of them plus the new rule in a single edit batch, then measure
exactly once at commit time. If that single measure is still net-positive, make
one decisive scaffolding cut — never a third prose-trim-and-measure loop.
