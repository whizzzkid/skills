---
skill: wk-learn
date: 2026-11-03
type: gap
severity: medium
verified-against-source: n/a
---

Self-caught errors were captured only at retro time instead of in the response that caught them.

**What happened:** Three self-caught errors (a false required-status claim, a mid-mutation file nearly committed, a multi-round invariant gap) each got fixed immediately, but none triggered a same-response learning capture. Retro reconstructed all three (live: 0, reconstructed: 3).

**Root cause:** The live-capture rule fires on corrections, but in long fix loops the agent treats a self-caught error as routine progress and keeps fixing.

**Suggested fix:** Make "I was wrong about X" / "verifier refuted my claim" an explicit trigger phrase in the workflow's live-capture rule, so the capture happens in the same response as the fix.
