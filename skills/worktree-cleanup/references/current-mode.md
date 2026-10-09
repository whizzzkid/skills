# `--current` mode: clean the worktree you are inside

Remove the worktree you are inside (e.g., after [`wk-pr-merge`](../../pr-merge/README.md)); `git worktree remove`
cannot remove the cwd, so chdir to main first.

```bash
CURRENT_WT=$(git rev-parse --show-toplevel)
MAIN_WT=$(dirname "$(git rev-parse --git-common-dir)")
CURRENT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null)
```

1. `CURRENT_WT` == `MAIN_WT`: not in a linked worktree; report and stop. Never remove the repo root.
2. Verify `CURRENT_BRANCH` merged via SKILL.md Step 3; `unmerged`/`unknown`: stop and ask — never auto-remove unmerged
   work.
3. Run SKILL.md Step 4's retro + content-scan guard on `CURRENT_WT`; skip retro if it already ran this session (e.g.,
   `wk-pr-merge` Step 9).
4. Guard clean → remove:

   ```bash
   cd "$MAIN_WT"
   git -C "$CURRENT_WT" clean -fd      # only after disposable-paths gate
   git worktree remove "$CURRENT_WT"
   git branch -D "$CURRENT_BRANCH"
   git worktree prune
   ```

5. Report removed worktree/branch and new cwd (`MAIN_WT`), then stop — no full sibling scan.
