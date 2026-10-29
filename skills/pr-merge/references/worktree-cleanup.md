# Terminal worktree cleanup

- Run only inside a linked worktree checkout; skip from repository root.
- Capture the current worktree's path before chdir to main (Git refuses to remove the current worktree), then remove
  by that path — never `git wtr "{head}"`, which rebuilds `worktrees/{head}` and misses a directory whose name drifted
  from the branch name:

  ```bash
  wt=$(git rev-parse --show-toplevel)
  main=$(git worktree list --porcelain | awk 'NR==1{print $2}')
  cd "$main" && git worktree remove "$wt" && git branch -D "{head}"
  ```

- `git branch -D` force-deletes the local branch; the PR is already confirmed merged, so a branch-merged safety check
  is redundant.
- Dirty failure → inspect `git status --short`; delete only recognizable test-runner state, `tmp/`, or coverage
  artifacts and retry once. Genuine uncommitted work requires confirmation; never default to `--force`.
