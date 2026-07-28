---
skill: wk-pr-review
date: 2026-07-27
type: correction
severity: medium
verified-against-source: n/a
---

Agent paused mid-task after receiving process feedback unrelated to the in-flight action, instead of completing the already-approved step.

**What happened:** After the user corrected the agent's test-scoping approach (a process complaint), the agent's next reply only acknowledged the feedback and stopped, leaving an already-approved action (posting a prepared pending review) undone. The user had to explicitly say "complete posting the review... why did you stop."

**Root cause:** No instruction distinguishes "acknowledge and adjust future behavior" from "acknowledge and also finish the current, already-authorized action" — the agent conflated taking feedback with pausing all forward progress.

**Suggested fix:** When a correction targets *how* work was done (process/efficiency) rather than *what* is about to be posted/shipped, acknowledge briefly in the same turn and then complete the already-approved pending action — only stop forward progress when the correction casts doubt on the correctness of that specific action.
