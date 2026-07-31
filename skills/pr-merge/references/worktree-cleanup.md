# Terminal worktree cleanup

- Run only inside a dedicated `worktrees/<name>` checkout; skip from repository root.
- Chdir to main before removal because Git refuses to remove the current worktree:

  ```bash
  main=$(git worktree list --porcelain | awk 'NR==1{print $2}')
  cd "$main" && git wtr "{head}"
  ```

- `git wtr` removes `worktrees/<name>` and force-deletes the local branch; the
  PR is already confirmed merged, so its branch-merged safety check is redundant.
- Dirty failure → inspect `git status --short`; delete only recognizable test-runner state, `tmp/`, or coverage
  artifacts and retry once. Genuine uncommitted work requires confirmation; never default to `--force`.
