---
skill: wk-concise
date: 2026-11-03
type: correction
severity: medium
verified-against-source: n/a
---

Open decisions for the user must be asked one at a time, never batched in a prose list.

**What happened:** After a drafting pass, the agent ended its response with three open decisions listed together in
prose. The user corrected it: always ask questions one by one, which they believed was already in their skills.

**Root cause:** No skill states a one-question-per-turn rule for user decisions. Brief mode encourages compressing
several open items into one closing list.

**Suggested fix:** Add a rule to wk-concise (and cross-reference it from wk-plan and wk-workflow): when the user has two
or more decisions to make, ask exactly one per turn with AskUserQuestion, wait for the answer, then ask the next. Never
list pending decisions in prose at the end of a response; mention only how many remain.
