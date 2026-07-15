---
class: principle
---

**Rule** — (1) On a merge signal, enter wk-pr-merge directly; never hand-do a
cosmetic pre-step (ticking PR-body checkboxes, editing the body) first — let the
Step 5 action-item scan decide what blocks. (2) When a push produces new-only
Minor/Info findings for ≥1 round ("bot-thrash"), surface it and offer
merge-now-with-deferred-follow-ups; only a fresh Blocker/Major justifies another
push.

**Why** — (1) Manual pre-steps duplicate or pre-empt the skill's own gates and can
diverge from them. (2) Push-triggered bot re-evaluation surfaces an unbounded tail
of low-severity findings; chasing each with another push never converges.

**Where** — wk-pr-merge "When to Use" HARD RULE; Step 4 Minor/Info triage
bot-thrash bullet.
