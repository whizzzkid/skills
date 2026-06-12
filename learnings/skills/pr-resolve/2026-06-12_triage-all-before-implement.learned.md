---
skill: wk-pr-resolve
date: 2026-06-12
type: correction
severity: high
---

Triage ALL comments one-by-one first, then implement all approved fixes in one batch.

**What happened:** Agent presented comment 1, received `a`, immediately implemented and committed it, then presented comment 2, received `a`, implemented and committed it. Each triage decision triggered an immediate implementation cycle.

**Root cause:** Misread the "one-at-a-time" rule as governing the full triage+implement loop rather than only the presentation step. The rule means: present one comment, collect its decision, then present the next — it does not mean implement after each decision.

**Suggested fix:** After collecting each triage decision, move to the next comment presentation immediately. Only after ALL comments are triaged should implementation begin. The sequence is: present→decide→present→decide→...→implement all→commit batch→push once.
