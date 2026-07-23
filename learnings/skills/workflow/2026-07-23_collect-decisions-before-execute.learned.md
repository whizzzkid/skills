---
skill: wk-workflow
date: 2026-07-23
type: correction
severity: medium
---

Decision-collection is a distinct phase that must fully complete before execution.

**What happened:** The user asked for judgements "1-by-1" and then interrupted with "before doing that collect all decisions first". The agent had begun interleaving asking for a decision and acting on it.

**Root cause:** No rule distinguishing "gather all approvals up front" from "execute per-approval"; the agent defaulted to act-as-you-confirm.

**Suggested fix:** When the user requests decisions gathered individually AND collected first, treat decision-collection as a barrier — gather every judgement, confirm the full set, then execute. Never interleave asking and doing.
