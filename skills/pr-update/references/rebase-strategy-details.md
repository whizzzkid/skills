# Rebase Strategy Details

```bash
git rebase "$BASE_REF"
```

**Merged-parent branches: rebase `--onto` to skip already-merged commits.** Branch
stacked on a parent that has since merged into base → plain `git rebase "$BASE_REF"`
replays the parent's commits too, producing add/add conflicts on files the parent
introduced. Replay only this branch's own commits:

```bash
# tip SHA of the now-merged parent branch (the old fork point)
git rebase --onto "$BASE_REF" <merged-parent-tip-sha>
```

- Detect: unexpected add/add conflicts on files this branch never touched, right after a
  parent branch merged.
- Find the parent tip via `git log --oneline` (last commit before this branch's own
  work); re-run with `--onto`.
- **Retargeting a child is not rebasing it.** When a parent PR merges, retargeting
  each child's base only changes what the child is compared against — the parent's
  commits remain in the child, so its diff claims that work as its own. Replay each
  retargeted child with `--onto` and force-push; do it when the parent merges, not
  when a reviewer notices.
- **Squash-merged parent → cherry-pick over rebase.** Rebase through a squash delta
  conflicts on every commit touching squashed lines. Cherry-pick the child's commits
  onto the post-squash base to skip the delta entirely.
- **Resolving in place instead of restarting** — merge strategy, parent already
  squash-landed: take `--theirs` for files the squashed parent fully supersedes,
  hand-merge files both histories added to, then gate on the full suite. In a merge
  `--theirs` is the incoming base and `--ours` the PR branch; inverted, this discards
  the branch's own work. Prefer `--onto` whenever the replay has not started yet.

**Base moved / stacked parent merged mid-flight → rebase the WHOLE stack.** Treat a moved
base as a first-class event. When a stacked PR's parent merges externally, or GitHub's
auto-update-branch silently merges the new default into a descendant (injecting an
unrelated lockfile delta and a synthetic `Merge branch …` commit, and retargeting the
base), rebase the entire current stack onto the new base — never patch around the injected
merge or accept the pollution:

```bash
git rebase --onto <newbase> <oldbase> <branch> --update-refs
```

- Detect an auto-merge: the remote branch head is a SHA absent from locally-fetched
  history (a `bad object`/unknown-SHA head). Re-fetch and inspect before trusting local refs.
- **After any `--update-refs` (or stack-rewriting) rebase, verify HEAD before the next Write
  or commit.** `--update-refs` moves branch *pointers* but leaves HEAD on whatever branch was
  checked out for the rebase — not the topmost branch. Run `git branch --show-current` /
  `git status` and explicitly `git checkout` the intended branch, or the next commit lands on
  the wrong branch of the stack.
- **A rebase reporting success may have done nothing.** `git rebase <base>` no-ops
  when `<base>` already equals the merge-base, keeping every SHA; `--rebase-merges`
  does not defeat it. Recreating commits for a side effect (re-sign, re-author) needs
  `--force-rebase`, and the proof is `HEAD != $START_SHA` — never a clean exit.
- Rebase reports conflicts → **conflict resolution loop** (Stage 4). Clean rebase → jump
  to Stage 5.
- Rebase introduces test failures or behavioral regressions (detected in Stage 5) →
  safety net `git reset --hard $START_SHA` restores the pre-rebase state (Stage 6 abort
  path).
