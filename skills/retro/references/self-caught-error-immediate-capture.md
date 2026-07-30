---
class: principle
---

**Rule:** A self-caught error — discovering a bug, finding a missing check, or correcting your own code mid-task — triggers an immediate `wk-learn` in that same response, before/alongside/after the fix commit. Do not defer it to retro.

**Why:** The former retro-only rule named self-caught errors, but a hook bug was
still logged only at retro. Deferral loses the exact error mode and diagnosis.

**Where:** [`wk-workflow`](../../workflow/README.md) Mandatory Activation owns
the self-caught-error trigger; [`wk-retro`](../README.md) Step 1.6 audits it.
