---
class: principle
skill: wk-retro
date: 2026-07-28
---

# Audit whether learnings were captured live

- **Rule:** Classify retro findings as live or reconstructed, report both counts,
  and invoke every missing per-skill learning call.
- **Why:** A retro can recover missed evidence but cannot restore the precision
  lost when a correction or self-caught error was not captured in its response.
- **Where:** [`wk-workflow`](../../workflow/README.md) owns the always-loaded
  capture trigger; [`wk-retro`](../README.md) audits compliance.
- **Escalation:** The workflow rule already existed when the miss recurred, so it
  moved from Phase 8 into Mandatory Activation instead of gaining more wording.
- **Budget:** 64-byte fold plus 79-byte linked-rule reclaim:
  24,464 → 24,449 of 24,576.
