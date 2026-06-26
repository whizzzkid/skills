---
skill: wk-pr
date: 2026-06-26
type: correction
severity: high
---

Self-review was deferred until after CI instead of posted in parallel.

**What happened:** After `gh pr create`, the agent launched CI polling and waited for green before invoking `wk-self-review`. The skill explicitly requires self-review to run *in parallel* with CI — not after.

**Root cause:** The intuitive "CI green → then review" ordering overrode the HARD RULE. The rule exists because CI takes minutes; staging the self-review draft in that window means the PR is closer to ready when CI finishes.

**Suggested fix:** Add a mandatory parallel-launch checklist item immediately after `gh pr create`: invoke `wk-self-review` in the same turn as the CI poll launch — treat deferral as a blocker-equivalent.
