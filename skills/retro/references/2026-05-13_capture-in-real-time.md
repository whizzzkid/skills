---
date: 2026-05-13
slug: capture-in-real-time
---

- **Rule:** Invoke `wk-learn <affected-skill>` in the same response that acknowledges a correction; do not defer first capture to retro.
- **Why:** Retro reconstructs from memory and drops precision, with some corrections never recovered. Retro refines and promotes — it cannot also be the first writer.
- **Where:** [`wk-workflow`](../../workflow/README.md) Mandatory Activation owns
  the trigger; [`wk-retro`](../README.md) Step 1.6 audits it.
