---
skill: wk-pr-merge
date: 2026-11-17
type: gap
severity: low
verified-against-source: n/a
---

A PR whose only approval comes from a bot can satisfy the platform's review decision yet still be refused by the agent's permission layer as "merge without review".

**What happened:** reviewDecision was APPROVED (from an automated reviewer), checks were green, merge state was clean, and the agent's merge call was denied by the permission classifier because no human had reviewed.

**Root cause:** Step 3 treats any APPROVED decision as sufficient and never checks who approved.

**Suggested fix:** In Step 3, list approving reviewers; if every approver is a bot, tell the user before attempting the merge and offer: merge it yourself, get a human approval, or add a permission rule.
