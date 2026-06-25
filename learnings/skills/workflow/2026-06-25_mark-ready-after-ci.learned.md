---
skill: wk-workflow
date: 2025-06-25
type: correction
severity: high
---

After CI passes on a PR branch push, mark the PR ready in the same turn — do not end the turn announcing CI passed.

**What happened:** CI passed on a pushed branch. The agent ended the turn stating "CI is now running — once it passes, mark ready with `gh pr ready`" without actually watching CI and executing the action. User had to ask "why didn't you mark it ready?"

**Root cause:** wk-workflow Phase 5 HARD RULE ("never end a turn with a draft PR whose work is done") was not applied. The agent treated CI polling as a hand-off point rather than continuing through `gh pr ready`.

**Suggested fix:** After every push to a branch that has an open draft PR, immediately poll CI to completion and call `gh pr ready` once green — never end a turn by delegating `gh pr ready` to the user as a manual step when the work in this turn is done.
