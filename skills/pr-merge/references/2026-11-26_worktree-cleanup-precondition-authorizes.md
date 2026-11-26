---
class: principle
---

# Worktree cleanup: the precondition check is the authorization

**Rule** — Remove the merged worktree without asking once every precondition holds: `git status --short` empty
(after throwaway-artifact cleanup), local `HEAD` equal to the merged PR's `headRefOid`, and no open PR targeting the
head branch. The worktree being the session's current directory is not a failed precondition. Ask only when one
fails, naming which, and report the removal afterwards.

**Why** — A general "confirm before deleting" caution overrode a step the skill already authorizes, costing a round
trip after merge, ticket transition, and retro had all landed. Compare SHAs rather than ancestry: a squash merge
creates a new commit, so `merge-base --is-ancestor` fails on a fully merged head. The existing reference rule that
direct invocation authorizes the documented branch-deletion default lived only in a reference file and did not reach
worktree removal, so this lands as a `SKILL.md` HARD RULE.

**Where** — `SKILL.md` → Steps 9–10 (Step 10 removal); procedure in
[`worktree-cleanup.md`](worktree-cleanup.md).

## Rejected suggestion

The report proposed tolerating untracked files that are undistilled learnings. **Rejected:** that relaxes the clean
status guard, and `git worktree remove` refuses untracked files without `--force`, which would destroy the queue
items. Untracked learnings are genuine uncommitted work — move or commit them, or ask.
