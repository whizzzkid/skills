# Push and Sync PR Description

Branch is now correct; publish without dropping a concurrent remote advance,
then align the PR with the pushed state.

## Push

- **Merge strategy → normal push.** Never force-push a merge-style branch:

  ```bash
  git push
  ```

- **Non-fast-forward after a local integration commit → fetch, inspect, merge,
  and re-validate.** The remote may have gained another contributor's commit or
  an automated base merge after Stage 1. Preserve both histories:

  ```bash
  git fetch origin "+refs/heads/$BRANCH:refs/remotes/origin/$BRANCH"
  REMOTE_SHA=$(git rev-parse "refs/remotes/origin/$BRANCH")
  git log --left-right --oneline HEAD..."$REMOTE_SHA"
  git merge "$REMOTE_SHA"
  ```

  Bind the comparison and merge to the resolved SHA of the explicit refspec's
  destination: a bare single-branch fetch does not guarantee `origin/$BRANCH`
  moved, and `FETCH_HEAD` is shared by every linked worktree, so a concurrent
  fetch elsewhere can overwrite it between the fetch and the read. Inspect
  the left/right log before merging. Unexpected remote scope → stop and surface
  it. Conflict → Stage 4. Clean merge or resolved conflict → rerun all of Stage
  5, then retry a normal `git push`; pre-remote validation does not carry
  forward. Never switch to `--force-with-lease` to bypass the remote commits.
  Applies only while the old upstream is still an ancestor of the fetched
  remote and `git cherry "@{u}" HEAD` prints no `-` line; otherwise the remote
  was rewritten → next bullet.
- **Remote rewritten under unpushed local commits → replay only those commits
  onto the live tip.** Stack tooling can linearize a layer onto the default
  branch and retarget its PR after a lower layer merges; local merge commits
  vanish and the next push is rejected. Capture the old upstream before
  fetching, then detect and replay:

  ```bash
  OLD_UPSTREAM=$(git rev-parse "@{u}")
  git fetch origin "+refs/heads/$BRANCH:refs/remotes/origin/$BRANCH"
  LIVE_TIP=$(git rev-parse "refs/remotes/origin/$BRANCH")
  git merge-base --is-ancestor "$OLD_UPSTREAM" "$LIVE_TIP"  # rc 1 = rewritten
  git cherry "$LIVE_TIP" HEAD                               # '-' line = rewritten
  git diff --quiet "$OLD_UPSTREAM" "$LIVE_TIP"              # rc 0 = history-only
  git rev-list --merges "$OLD_UPSTREAM..HEAD"               # non-empty → stop
  git switch --detach "$LIVE_TIP"
  git cherry-pick "$OLD_UPSTREAM..$BRANCH"
  git switch -C "$BRANCH"                                   # repoint local branch
  git push                                                  # fast-forward
  ```

  - Already fetched since the rewrite → `@{u}` is the live tip and the
    ancestor test passes vacuously; the `git cherry` `-` line still flags it.
    Take the old upstream from the tracking ref's reflog
    (`git rev-parse "@{u}@{1}"`) or the SHA the last push reported.
  - Tree diff non-zero → the rewrite also changed content: rerun all of
    Stage 5 after the cherry-pick, before the push.
  - Cherry-pick conflict or a merge commit in the range → `git cherry-pick
    --abort`, `git switch "$BRANCH"`, stop and surface.
  - Never merge the stale local history back in (reinstates the commits the
    rewrite discarded, duplicating merged layers) and never force-push over the
    rewritten branch (discards the tool's rebase and retarget).
  - Branch is a `gh stack` layer → land the replay first, then propagate later
    parent changes with `gh stack sync` per `wk-pr`'s stacking rules, not a
    merge (its cascade rebase and `--force-with-lease` push discard merge
    commits).
- **Rebase or patch-replay strategy → rewritten history.** Push with a lease:

  ```bash
  git push --force-with-lease
  ```

  Lease rejection means the remote advanced → fetch and restart from Stage 1.
  Never escalate to `--force` or merge the pre-rewrite remote history back into
  a deliberately rewritten branch.

## Sync the PR After the Push

Invoke the PR Sync flow from `wk-commit` (HARD RULE: post-push, PR title and body must
reflect the post-push branch state). For patch-replay specifically, also update:

- PR body's commit list / "What's included" section, if present — branch is now one
  squashed commit, not N.
- Metadata lines (issue-closing annotations, co-author trailers, automation blocks,
  ticked test-plan checkboxes) — **HARD RULE:** preserve verbatim per
  `skills/pr/references/pr-description-metadata.md`.

No PR yet (skill ran on a local branch) → skip the sync step and stop after the
validated integration — the user wanted "update", not "create".
