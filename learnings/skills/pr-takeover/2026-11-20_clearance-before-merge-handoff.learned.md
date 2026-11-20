---
skill: wk-pr-takeover
date: 2026-11-20
type: gap
severity: medium
verified-against-source: n/a
---

A takeover chained into a merge reaches the merge gate with no adversarial-review clearance record.

**What happened:** The user asked to validate locally, run a quick (light) PR review, then merge an inherited,
already-approved PR. Light review never dispatches the adversarial review, so the merge skill's clearance gate
stopped and the user had to be asked mid-flow; it also surfaced that the only approval was from a bot.

**Root cause:** The takeover flow defers adversarial review to the workflow's completion gate, but a "review then
merge" directive on an inherited PR skips straight from a light review to merge, so no clearance record ever exists.

**Suggested fix:** When a takeover directive ends in a merge, dispatch the adversarial review right after local
validation (before the light review) and check approver identity (bot-only vs human) up front, so the merge gate
is satisfied without a mid-flow question.
