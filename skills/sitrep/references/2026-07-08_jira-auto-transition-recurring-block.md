---
class: principle
skill: wk-sitrep
date: 2026-07-08
severity: medium
---

- **Rule:** A Stage 2b auto-transition denial is deterministic, not stochastic —
  the harness write-permission classifier blocks every auto-transition of a
  ticket this session did not create. On first denial, block-register the key and
  stop re-attempting on later runs: re-verify merge state and render the ticket as
  `🔁 blocked N days`, pinned in ASAP until the user transitions it manually.
- **Why:** The prior fold added graceful degradation on denial (carry-forward,
  don't retry within a run), but the skill still re-attempted the same merged-PR
  ticket every subsequent `start`, producing the identical denial daily and
  re-rendering it as a fresh carry-forward instead of a persistently-blocked item.
  The denial category never changes outcome across runs, so re-attempting is pure
  waste.
- **Where:** Stage 2b — replaced the single-run degrade rule with deterministic
  denial + cross-run block-register + skip re-attempt + `🔁 blocked N days` render.
