---
class: principle
---

**Rule** — Fold a skill's terminal "Post-Completion" instruction (e.g. the
`wk-learn` capture) into the last numbered stage of each flow. Never leave it as
a detached appendix below the Quick Reference table.

**Why** — A stage list that ends at "Stage N: Commit and push" reads as the full
lifecycle. A trailing Post-Completion section with no stage number and no callback
from the final stage is treated as done-at-commit and never re-visited — the same
failure class as a verify step described in prose instead of gated as a hard stage.

**Where** — wk-sitrep: `start` Stage 6 and `end` Stage 8 now close with an explicit
`wk-learn sitrep` invocation; the standalone Post-Completion section was deleted.
