---
skill: wk-plan
date: 2026-06-25
type: correction
severity: medium
---

In auto mode, an implementation directive in the original prompt is implicit plan approval — do not re-ask.

**What happened:** The original prompt ended with "Fix this for all the hidden comment types." After invoking wk-workflow and wk-plan, the agent presented the plan and blocked on "Proceed?" — requiring the user to confirm again. The user was frustrated: their original directive was the approval.

**Root cause:** The wk-plan HARD RULE ("wait for explicit approval") was applied mechanically without recognising that auto mode + a clear imperative in the original message already constitutes approval. The agent treated silence-from-plan as the gate rather than reading the original message intent.

**Suggested fix:** In auto mode, when the user's original message contains an unambiguous implementation directive ("fix this", "implement this", "make this change"), treat the plan as approved and proceed immediately after presenting it. Only block on approval when the plan is genuinely speculative or the user's intent is unclear.
