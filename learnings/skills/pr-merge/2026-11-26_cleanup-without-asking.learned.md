---
skill: wk-pr-merge
date: 2026-11-26
type: correction
severity: medium
verified-against-source: n/a
---

Step 10 worktree cleanup is part of the skill's mandate, so run it without asking once the safety preconditions hold. That includes when the worktree is the current working directory.

**What happened:** After the merge, the ticket transition and the retro, the agent stopped and asked permission to remove the merged PR's worktree. The worktree was clean, and its HEAD equalled the merged PR's `headRefOid`. The agent asked because removing it deletes the directory the session runs from. The user corrected this: do not ask, just do it.

**Root cause:** The general "confirm before deleting" caution overrode a step the skill already authorizes. Being the current working directory was treated as an extra risk, though nothing in it was unmerged.

**Suggested fix:** In Step 10, state that the precondition check is the authorization. Remove the worktree automatically when all four hold:
- `git status --short` is empty;
- HEAD equals the merged PR's `headRefOid` (a squash merge makes `merge-base --is-ancestor` fail, so compare SHAs instead);
- no open child PRs target the branch;
- there are no untracked files other than undistilled learnings.

Run the removal from the main checkout (`git -C <main-checkout> worktree remove <path>`, then `git -C <main-checkout> branch -D <branch>`), and report it afterwards. Ask only when a precondition fails.
