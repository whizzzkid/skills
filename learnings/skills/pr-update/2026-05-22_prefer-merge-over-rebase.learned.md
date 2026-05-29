---
skill: wk-pr-update
date: 2026-05-22
type: correction
severity: medium
---

Use `git merge origin/<base>` not `git rebase` when updating a PR branch.

**What happened:** Agent ran `git rebase origin/main` to incorporate a new commit that landed on main after the branch was created. This rewrote commit SHAs and required a force-push.

**Root cause:** Workflow instinct was to keep linear history via rebase, but for PR branches a merge is safer and avoids the force-push permission friction.

**Suggested fix:** In `wk-pr-update` and `wk-workflow`, default to `git merge origin/<base>` for incorporating base-branch advances onto a PR branch. Reserve rebase only when the user explicitly asks for clean linear history.

## Additional evidence

When merge conflicts surface during `git merge origin/main`, the agent should
quick-check conflict complexity before committing to resolution: count conflict
files and compare what a `git rebase --dry-run` (or `git rebase origin/main`
on a scratch branch) would require. The interruption "check if rebase is
simpler" signals that complexity comparison should happen before the agent
dives into manual conflict editing — a 30-second check beats 10 minutes of
conflict resolution on the wrong approach.
