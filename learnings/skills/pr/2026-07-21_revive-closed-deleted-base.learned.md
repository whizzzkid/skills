---
skill: wk-pr
date: 2026-07-21
type: gap
severity: medium
---

A CLOSED PR whose base branch was deleted cannot be reopened or retargeted.

**What happened:** Asked to revive a PR that auto-closed when its stacked base branch was squash-merged and deleted. `gh pr reopen` failed ("Could not open the pull request") and `gh pr edit --base` failed ("Cannot change the base branch of a closed pull request").

**Root cause:** GitHub refuses to reopen a PR when its base ref no longer exists; the revive path is a fresh PR, not a reopen.

**Suggested fix:** In the revive/takeover flow, detect `state == CLOSED` + missing base ref up front (`git ls-remote --heads origin <base>` empty), then rebase the delta onto the default branch (`git rebase --onto origin/<default> <last-base-commit> HEAD`) and open a new PR referencing the old one as superseded — skip the doomed reopen/retarget attempts.
