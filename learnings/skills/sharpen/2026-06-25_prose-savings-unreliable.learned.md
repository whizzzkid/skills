---
skill: wk-sharpen
date: 2026-06-25
type: correction
severity: medium
---

Estimate reclaim from structural moves (predictable bytes), not prose compression (unreliable) — at near-zero headroom, prose-savings guesses cause the very trim-measure loop the budget rule forbids.

**What happened:** Folding 3 rules into a skill with 25 B headroom, I planned reclaim up front (per the just-folded budget rule) but sized it from prose compression of dense bullets. Actual savings ran well under the guess: workflow measured -377, then -79, then -22, then +31 — four measure cycles, exactly the search-loop the rule was meant to prevent.

**Root cause:** Prose-compression byte savings are hard to predict — tightening a sentence can save 40 B or 120 B depending on wording, and I over-estimated each pass. Structural moves (merging 3 `### ` subsections into one bulleted block, deleting bullet/blank-line scaffolding) reclaim a predictable, countable quantity. The existing rule already says "prefer structural over prose-mangling"; this run shows the byte-budget math should also lean on structural reclaim because only structural savings are estimable in one pass.

**Suggested fix:** In Step 7.5's byte-budget rule, when computing the one-pass reclaim quantity at tight headroom, derive the estimate from a structural move (subsection merge, scaffolding removal) whose byte count is countable before editing — treat prose compression as the unreliable final-margin only, never the primary planned quantity.
