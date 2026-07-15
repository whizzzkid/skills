---
skill: wk-pr-resolve
date: 2026-07-15
type: correction
severity: medium
---

After resolving all review comments on a DRAFT PR, mark it ready for review without waiting to be asked.

**What happened:** The agent resolved review comments on a draft PR but left it in draft state; the user had to prompt twice ("did you mark it ready for review?" / "you should have, no?") before the agent ran `gh pr ready`.

**Root cause:** The resolve flow has no explicit step to transition a draft PR to ready once its comments are addressed, so the agent treated readiness as out of scope.

**Suggested fix:** Add a closing step: if the PR is a draft and all triaged threads are resolved/deferred, run `gh pr ready` (adversarial-review gate still applies) and announce it — do not leave a resolved PR sitting in draft.
