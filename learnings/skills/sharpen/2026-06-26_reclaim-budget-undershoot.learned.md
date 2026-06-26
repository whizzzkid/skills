---
skill: wk-sharpen
date: 2026-06-26
type: pattern
severity: medium
---

Reclaim budget undershoots when the drafted rule is bigger than the relocated block.

**What happened:** Folding high-sev rules into two skills already at the body ceiling
(headroom <60 B), I relocated one existing block to references/ to make room, then
measured — both went over (-98, -84). A second relocation/trim pass was needed each time,
which is the re-violation signal the measure-exactly-once rule warns against.

**Root cause:** I picked the reclaim target by rough size feel ("relocate row X, it's big")
without measuring the drafted rule first. When the new rule is a multi-clause HARD RULE or
a wide table row, it routinely exceeds the single block being relocated, so net stays
positive.

**Suggested fix:** When headroom is under ~2x the drafted edit, stage the new rule alone
and measure its exact byte size FIRST, then choose a reclaim target (or set of targets)
whose combined measured size strictly exceeds it — before applying the relocation. Treat
"one fat block out, one rule in" as net-positive by default for multi-clause rules; budget
two relocations or a relocation plus a why-to-references trim up front, so the first
post-edit measurement is already non-positive.
