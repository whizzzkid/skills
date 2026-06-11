---
skill: wk-pr-resolve
date: 2026-06-11
type: correction
severity: medium
---

Collect all judgment-required responses before implementing any of them.

**What happened:** Two judgment-required items were presented one at a time (correct), but each fix was implemented immediately after the user responded "a" — before the second item was even presented. This caused two separate pushes and two CI builds instead of one.

**Root cause:** Misread "one judgment-required item per message" as "implement after each confirmation." The rule governs presentation cadence (don't batch the asks), not implementation cadence.

**Suggested fix:** Present all judgment-required items sequentially (one per message, wait for reply). Record each decision. Only after all items are resolved — with confirmed actions (a/e) and dismissals (d) noted — implement the full set as a batch, commit, and push once.
