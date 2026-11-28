---
class: principle
source: learnings/skills/gh/2026-11-28_stack-rebases-after-merge.md
date: 2026-11-28
severity: medium
---

# A rewritten remote takes a replay, never a merge or a force-push

**Rule** — Push rejected non-fast-forward → test whether the old upstream SHA is
still an ancestor of the fetched remote. Not an ancestor → the remote was
rewritten: cherry-pick only the unpushed commits (`<old-upstream>..HEAD`) onto
the live tip, push as a fast-forward, repoint the local branch. Tree differs
from the old upstream → re-validate before the push. Merge commit in the range or
a cherry-pick conflict → stop and surface. On a `gh stack` stack, propagate later
parent changes with `gh stack sync`, not a merge.

**Why** — While a fix was committed locally on the top layer of a stack, the
lower layers merged. The top layer's remote branch came back as a linear rebase
onto the default branch, retargeted there, with the local merge commits gone;
the next regular push was rejected. The installed non-fast-forward default
(`git pull --no-rebase`, merge) assumes the remote only advanced. Against a
rewrite it reinstates the pre-rewrite commits the tool discarded, duplicating
merged layers; a force-push instead discards the tool's rebase and retarget.
The ancestor test separates "advanced" from "rewritten" before either default
fires; `git cherry` (a `-` line = a local commit already upstream under a new
SHA) covers a session that fetched after the rewrite, when the captured upstream
is already the live tip; the tree comparison reuses the existing "new SHAs over an identical tree"
stacked-chain rule.

**Verification** — Root cause partly verified: installed `gh stack` help
confirms `sync` cascade-rebases and pushes with `--force-with-lease`, so merge
commits on a layer do not survive tool-driven propagation. Whether the
post-merge rewrite is server-side or a client sync was not reproduced; the rule
keys on the observable (ancestor test), not on the actor. The detection and
replay recipe was reproduced in a throwaway two-clone repo: rewritten layer →
ancestor rc 1, `git cherry` `-` line, tree rc 0; the cherry-pick replay pushed
as a fast-forward with upstream tracking intact.

**Corrected over-general instances** — `wk-commit`'s non-fast-forward merge
default and `wk-pr-update` Stage 6's "fetch, inspect, merge" now apply only when
the old upstream is an ancestor; `wk-pr`'s same-anchor stacking offer and
`wk-pr-update` Stage 2's merge default defer to `gh stack sync` on a `gh stack`
stack.

**Rejected** — "Prefer the stack tool's sync" as the recovery for the rejected
push itself: the unpushed commit must land first, and the replay is the
inspected, fast-forward path.

**Where** — `wk-pr-update` Stage 6 (replay rule) and Stage 2 (stack pointer);
`references/push-and-sync.md` (commands); `wk-commit` Pushing; `wk-pr` Stacking
and `references/gh-stack-stacking.md`.
