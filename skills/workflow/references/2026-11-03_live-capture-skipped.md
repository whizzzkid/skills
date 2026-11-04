---
class: principle
---

# Live capture: CRITICAL label restored; refuted claims named as triggers

- **Rule:** A verifier refuting your claim, or any "I was wrong about X" moment, is a self-caught error. Capture it in
  the response that catches it, even mid fix loop.
- **Classification:** `already-covered` re-violation. "Self-caught error" has been a trigger since 2026-07-30, yet three
  self-caught errors in one session (a refuted claim, a near-commit of a mutated file, a multi-round invariant gap) were
  all reconstructed at retro (live: 0).
- **Escalation:** The ladder reached rung 4 (`CRITICAL`) on 2026-08-28, but a 2026-10-08 prose-compression pass
  dropped the label. This fold restores rung 4 and does not add a notch, because the violation happened against the
  degraded text, which never tested `CRITICAL`. Next re-violation → rung 5 (`HIGH-PRIORITY`).
- **Why:** In long fix loops a self-caught error reads as routine progress. Naming the concrete moments ("verifier
  refuted my claim") gives the trigger a recognizable surface.
- **Where:** [`wk-workflow`](../README.md) → Mandatory Activation → live learning capture. Filed against `wk-learn`;
  the trigger rule lives in `wk-workflow`.
