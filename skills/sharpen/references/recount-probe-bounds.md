---
class: principle
---

# Bounding a drift-check recount probe (Step 7)

The imperative lives in `SKILL.md`; this file carries the procedure and the
failure modes behind it.

## Prove the anchor unique before trusting the count

- Count the anchor's occurrences first. One occurrence → the range is bounded.
- Repeats → select the occurrence explicitly (an Nth-occurrence match, or a
  second anchor that closes the range) and re-run. Never trust a range probe
  whose start pattern matches more than once.
- A section heading is the usual repeat offender: the same stage or phase name
  often appears under two sub-commands, so a range opened on it restarts at the
  later occurrence and runs past the intended section, sweeping in bullets from
  unrelated blocks.

## Both directions are probe defects

- The recount rule's stated failure signal used to be a zero ("mismatch → 0 =
  phantom drift"), which guards only one direction. An **over-count** is equally
  a probe defect — an unbounded range consuming later sections reports a number
  larger than the documented set, and the drift it reports is phantom too.
- Shape and liveness guards do not bound extent. A probe can match the source
  markup and visibly fire, and still consume three sections it was never meant
  to reach.

## A passing member control cannot distinguish the two

- The "prove it fires on a known member" tripwire is satisfied by a probe that
  over-runs: a member printed from inside the intended section looks identical
  to one printed by a probe that also spans everything after it. The control
  actively reassures while the number is wrong.
- **Print the matched members and confirm each belongs to the intended section**
  rather than trusting a bare count, wherever that is cheap. A count discards
  exactly the evidence that would expose the over-run.

**Where** — `SKILL.md` → Step 7 → *Drift check* → recount bullet.
