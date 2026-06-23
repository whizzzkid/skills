---
skill: wk-commit
date: 2026-06-23
type: correction
severity: medium
---

`git commit --amend` is blocked in auto mode; CI fix commits accumulate and require manual `git rebase -i` to squash.

**What happened:** After a CI fix produced a follow-up commit that should have been squashed into the previous one, auto mode blocked `git commit --amend` as a destructive operation. The user had to run `git rebase -i HEAD~2` manually to consolidate.

**Root cause:** Auto mode treats `--amend` as history-rewriting and requires explicit user confirmation. The wk-commit skill's squash-noisy-commits guidance applies, but the agent cannot execute the amend without approval.

**Suggested fix:** When a CI fix produces a trivial follow-up commit that's clearly a correction to the immediately prior commit, surface the explicit suggestion for the user to approve `--amend` in the same response. Do not silently create a separate commit and leave cleanup to retro — ask once at the fix site.
