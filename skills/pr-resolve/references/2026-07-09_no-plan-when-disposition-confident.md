---
class: principle
skill: wk-pr-resolve
date: 2026-07-09
severity: medium
---

- **Rule:** The Step 4 non-convergence "new finding contradicts an accepted fix →
  stop and ask" trigger fires only when the contradiction is genuinely unresolved.
  When the contradicting finding has a confident, evidence-backed disposition
  (established convention, schema/contract guarantee, prior rationale still holds),
  it is decided under Auto Mode — dismiss with the rationale and act, no plan, no
  per-item confirmation.
- **Why:** A round-2 bot finding flagged an earlier-accepted `.fetch` fix as a
  regression. Reading the stop-and-ask branch literally, the agent proposed a
  dismiss-plus-fix plan and waited; the user cut in ("fix this, why did we create
  a plan") because the dismissal rationale (established convention, schema-
  guaranteed field, several existing call sites) was already conclusive. The
  branch was applied as an unconditional pause, overriding the Auto-Mode rule that
  a confident evidence-backed disposition is acted on, never confirmed per-item.
- **Where:** Step 4 Bot/non-convergence handling — scoped the contradiction
  trigger with an Auto-Mode-confident exception. Pairs with the wk-adversarial-
  review bot flip-flop guard.
