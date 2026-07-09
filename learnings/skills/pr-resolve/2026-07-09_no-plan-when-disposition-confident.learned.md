---
skill: wk-pr-resolve
date: 2026-07-09
type: correction
severity: medium
---

A bot finding that contradicted an earlier-accepted fix triggered a full
plan-and-ask pause when the disposition was already evidence-backed and should
have been acted on directly.

**What happened:** A round-2 bot finding flagged `.fetch("severity")` (an
earlier-accepted fix) as a regression. Reading the Step 4 non-convergence rule
("stop and ask when a new finding contradicts an accepted fix") literally, the
agent proposed a dismiss-plus-fix plan and waited. The user cut in: "fix this,
why did we create a plan." — the dismissal rationale (established convention,
schema-guaranteed field, 4+ existing call sites) was already conclusive.

**Root cause:** The non-convergence "stop and ask" branch was applied as an
unconditional pause on any accepted-fix contradiction, ignoring that Auto Mode
already decides any finding with a confident, evidence-backed disposition
(apply *or* dismiss) → act and report, never confirm per-item.

**Suggested fix:** In Step 4's non-convergence handling, scope the "new finding
contradicts an accepted fix → stop and ask" trigger to cases where the
contradiction is *genuinely unresolved*. When the contradicting finding has a
confident evidence-backed disposition (convention cited, schema/contract
guaranteed, prior rationale still holds), treat it as decided — dismiss with the
rationale and proceed, no plan, no per-item confirmation.
