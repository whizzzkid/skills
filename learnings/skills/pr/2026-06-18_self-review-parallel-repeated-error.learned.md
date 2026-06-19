---
skill: wk-pr
date: 2026-06-18
type: correction
severity: medium
---

Self-review was posted after CI green despite an existing learning saying to post it in parallel.

**What happened:** Agent waited for CI to pass before invoking wk-self-review, then ran adversarial review, then marked PR ready — serial when it should be parallel. The wk-pr skill says "invoke wk-self-review immediately after gh pr create" but the agent deferred to post-CI.

**Root cause:** Distilled learning (`self-review-before-ci-poll.learned.md`) had not propagated back into the live skill instructions. Agent defaulted to the intuitive "CI green → then do review work" mental model instead of the parallel model the skill mandates.

**Suggested fix:** Add an explicit, numbered gate in wk-pr Step 3: "IMMEDIATELY after `gh pr create` returns, invoke wk-self-review (do not wait for CI). Waiting for CI to post self-review is a recurring violation — treat it as a blocker equivalent."
