---
skill: wk-sharpen
date: 2026-06-29
type: correction
severity: medium
---

Underbudgeting the byte reclaim by a few bytes triggered the forbidden measure-trim thrash loop

**What happened:** Folding a new rule pushed the body 246 B over the size ceiling. I planned three coverage-preserving reclaims that summed to ~243 B — just short. The result landed 3 B over, then I trimmed again (−11), again, and a third time before a decisive scaffolding cut (deleting two redundant code-block comments) finally cleared it with margin. That is exactly the "second measure-and-trim cycle = re-violation signal, stop and re-plan" pattern the de-bloat rule forbids.

**Root cause:** I summed reclaim candidates to *approximately* the overage instead of *strictly exceeding it with margin*, and I ordered the reclaims weakest-first — the highest-yield, zero-risk cut (redundant inline code comments already explained by adjacent prose) was applied last instead of first. The rule says budget reclaims whose combined size strictly exceeds the overage; "roughly equal" reopens the loop.

**Suggested fix:** When reclaiming, pick targets summing to overage + a safety margin (e.g. ≥1.2×), and apply the single largest zero-coverage-risk cut (scaffolding: inline comments, alignment whitespace, blank lines) FIRST, before tightening prose. If the first post-reclaim measure is still over by any amount, treat it as the stop-and-re-plan signal — make one decisive scaffolding cut, not another prose nibble.
