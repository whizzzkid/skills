---
skill: wk-pr-update
date: 2026-07-22
type: gap
severity: high
---

When the base moves under a stacked PR set, rebase the whole stack onto the new base.

**What happened:** Mid-work on a stacked PR set, the parent PR merged externally
and GitHub's auto-update-branch feature silently merged the new default branch
into the descendant PR's branch — introducing an unrelated lockfile delta and a
synthetic "Merge branch ..." commit, and retargeting the descendant's base. The
agent surfaced three options (drop the merge, rebase the whole stack, or accept
the noise); the user's standing instruction was to always rebase the entire
current stack onto the new base.

**Root cause:** The skill had no explicit playbook for "base moved / a
stacked-PR parent merged mid-flight." Auto-update-branch merges are easy to miss:
the branch head advances to a SHA absent from locally-fetched history.

**Suggested fix:** Treat a moved base as a first-class event. When a stacked PR's
parent merges or the base advances, rebase the *whole* stack onto the new base
(`git rebase --onto <newbase> <oldbase> <branch> --update-refs`), producing a
clean diff-vs-new-base, rather than patching around the injected merge commit or
accepting the pollution. Detect it by comparing the remote branch head against
locally-fetched history (a "bad object"/unknown-SHA head means re-fetch and
inspect for an auto-merge before trusting local refs).
