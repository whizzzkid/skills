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
  git fetch origin "$BRANCH"
  REMOTE_SHA=$(git rev-parse FETCH_HEAD)
  git log --left-right --oneline HEAD..."$REMOTE_SHA"
  git merge "$REMOTE_SHA"
  ```

  Bind the comparison and merge to `FETCH_HEAD`'s resolved SHA; an explicit
  single-branch fetch does not guarantee that `origin/$BRANCH` moved. Inspect
  the left/right log before merging. Unexpected remote scope → stop and surface
  it. Conflict → Stage 4. Clean merge or resolved conflict → rerun all of Stage
  5, then retry a normal `git push`; pre-remote validation does not carry
  forward. Never switch to `--force-with-lease` to bypass the remote commits.
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
