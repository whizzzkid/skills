---
skill: wk-pr-resolve
date: 2026-06-10
type: correction
severity: low
---

Do not run `git status` as a context-gathering step inside the adversarial review phase of wk-pr-resolve.

**What happened:** When setting up context for an adversarial review, the agent ran `git status`. The user interrupted the tool call — `git status` in that context was unnecessary and reads as aimless exploration rather than purposeful review setup.

**Root cause:** The adversarial review needs the diff surface (from `git diff`), not the working-tree status. Running `git status` at review time implies uncertainty about what was committed, which should have been resolved by the earlier commit step.

**Suggested fix:** When entering the adversarial review gate, read the diff directly (`git diff $BASE...HEAD`) rather than checking working-tree status. Reserve `git status` for pre-commit checks only.
