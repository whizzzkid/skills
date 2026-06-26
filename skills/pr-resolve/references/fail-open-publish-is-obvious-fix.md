---
class: principle
skill: wk-pr-resolve
date: 2026-06-26
---

**Rule:** A bot/reviewer finding that names swallowed errors, silent returns,
or fail-open behavior in a script that writes or publishes external artifacts
(CI publish/upload steps) classifies as `obvious-fix`, not `judgment-required`.
Fail-closed is the correct default; swallowing query/API uncertainty risks
duplicate or missed publishes. Exception: the calling context explicitly
requires idempotent pass-through.

**Why:** Existing silent-return behavior reads as an intentional design
tradeoff, so the agent over-classifies the fix as judgment-required and leaves
an empty skip rationale. In any artifact-publishing path there is no valid skip
rationale — empty rationale + publish context = obvious-fix.

**Where:** Step 4 classification table, `obvious-fix` condition cell.
