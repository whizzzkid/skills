---
skill: wk-goodmorning
date: 2026-05-12
type: correction
severity: high
---

Invoked wk-sharpen (direct skill edits) instead of wk-learn (capture for later distillation).

**What happened:** User said "make a learning" and agent invoked wk-sharpen, which directly modified skill files in the skills repo. User explicitly requires that direct skill edits never happen without their approval — the correct flow is wk-learn to capture, wk-sharpen later (user-triggered) to distill.

**Root cause:** Agent interpreted "make a learning to sharpen" as permission to run wk-sharpen. The phrase "make a learning" means capture via wk-learn. The skills path is managed by a separate repo and is effectively read-only unless the user explicitly runs wk-sharpen.

**Suggested fix:** When the user says "make a learning", "capture this", or "note this for later" — always use wk-learn. Only invoke wk-sharpen when the user explicitly says "sharpen the skill", "apply this to the skill", or "update the skill now". The distinction: wk-learn = write to learnings/, wk-sharpen = rewrite the SKILL.md.
