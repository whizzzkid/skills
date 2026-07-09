---
class: principle
skill: wk-adversarial-review
date: 2026-07-09
severity: medium
---

- **Rule:** On a fail-mode finding (`.fetch(k)` vs `h[k]` / strict vs lenient
  access on a required field), resolve it by evidence, not first principles:
  grep siblings in the same module for the established access convention, and
  check whether the field is schema-guaranteed (producer always emits it). Both
  present → fail-fast (`.fetch`) is correct; dismiss the fail-open finding. When
  an automated reviewer re-fires on a line it earlier pushed you to change, treat
  the contradiction as a stop signal — dismiss citing the invariant, never
  oscillate the code between the two findings.
- **Why:** A shared counting helper read a required `severity` field. Round 1 a
  bot flagged bracket access as fail-open (silent nil → miscount); after
  switching to `.fetch`, a later round the same bot flagged it as a fail-fast
  "regression" (raises on malformed input). The two findings contradict on one
  line. Which is right depends on a schema invariant the line-local reviewer
  cannot see; it re-derives the opposite each pass. Convention + guarantee make a
  missing key corrupt data that must surface, so fail-fast wins.
- **Where:** Row 2.3 already mandates strict access at a partition boundary when
  the producer guarantees the field; added the flip-flop guard to Bot Reviewer
  Handling.
