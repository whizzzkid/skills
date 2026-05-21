---
skill: wk-pr
date: 2026-05-20
type: correction
severity: high
---

After creating a draft PR, agent returned control to user without completing post-creation steps.

**What happened:** After `gh pr create` succeeded, the agent reported the PR URL and stopped — skipping CI polling, `wk-self-review`, automated feedback triage, and `gh pr ready`.

**Root cause:** The agent treated PR creation as the terminal action rather than the midpoint of the wk-pr workflow. The remaining steps (Steps 3–6) were not invoked.

**Suggested fix:** After every `gh pr create`, immediately proceed to Step 3 (update description, poll CI) without returning control. The only valid stopping points before `gh pr ready` are: CI failing after 3 fix attempts, or a `blocked` adversarial-review verdict requiring user design input.
