---
class: principle
source: learnings/skills/sitrep/2026-11-19_skill-call-own-turn.learned.md
date: 2026-11-19
skill: wk-sitrep
---

**Rule** — At close, commit and push first, read the output, then issue the learning-capture Skill call in its own
response. Never batch it with the patch/commit shell call.

**Why** — The closing stage listed `wk-learn` before the commit, which invites issuing both in one response. In the
observed run the batched Skill call got no permission verdict and had to be retried alone. Sequencing it after the
commit also lets the learning reflect the final commit/push outcome.

**Classification** — `principle` (ordering defect in the stage text). The classifier-batching root cause is
unverified and inferred from one symptom; the permission classifier is probabilistic, so a passing retry is not proof.
The fold rests on the ordering fix, not on that hypothesis.

**Where** — `SKILL.md` → `end` Stage 8 (sub-bullet) and `start` Stage 7 (cross-reference).
