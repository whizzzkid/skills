---
class: principle
---

# Never branch from or read `FETCH_HEAD` in a linked-worktree repo

**Rule** — After a fetch, branch from (or resolve) the remote-tracking ref (`origin/<default>`, or the destination of
an explicit `+src:dst` refspec), never `FETCH_HEAD`. Verify with `git log -1 origin/<default>` before branching.

**Why** — Linked worktrees share the common git dir, and `FETCH_HEAD` lives there. A fetch in any other worktree
overwrites it, so `git fetch origin <default>` followed by `git switch -c <branch> FETCH_HEAD` can create the branch
from an older, unrelated commit; `git cat-file -p FETCH_HEAD` showed a commit that did not belong to the fetch just
run. The new branch silently lacked recent default-branch commits.

**Where** — `SKILL.md` → Phase 5 → Repo convention bullet. Re-violation of the installed baseline rule "follow-up
branch → from `origin/<default>` (fetch first)" → escalated one rung to `**Important:**` and given the `FETCH_HEAD`
failure mode. Over-general instances corrected in the same fold: the pr-update non-fast-forward recipe and the sitrep
per-PR review-worktree recipe now fetch into an explicit ref and resolve that ref instead of `FETCH_HEAD`. Bytes for
the escalation were reclaimed by deleting a Phase 7 clause duplicated by the stricter "never bootstrap" bullet.
