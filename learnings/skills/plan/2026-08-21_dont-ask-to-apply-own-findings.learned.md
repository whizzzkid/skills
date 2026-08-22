---
skill: wk-plan
date: 2026-08-21
type: correction
severity: medium
verified-against-source: n/a
---

Asked user permission to apply self-generated arch-review findings to the plan instead of applying them immediately.

**What happened:** After running wk-arch-review on the plan and producing 6 findings with concrete recommendations, the agent asked "Want me to revise the plan with these fixes incorporated?" instead of revising immediately. The user corrected with "yes of course, what are you waiting for?"

**Root cause:** The agent treated its own review findings as external feedback requiring user confirmation, despite wk-workflow explicitly stating "pre-flight findings are mandatory actions, not options — fold blockers/improvements into the relevant artifact and commit. Pause only for a genuine user-owned design decision." The arch-review findings were all technical (SQL subqueries, dedup, index) — none required a design decision.

**Suggested fix:** Add to wk-plan Step 4 (Validate): "When wk-arch-review produces findings, fold them into the plan immediately — they are mandatory corrections, not proposals. Re-present the updated plan only if the changes alter scope, phasing, or PR count; otherwise apply silently and proceed."
