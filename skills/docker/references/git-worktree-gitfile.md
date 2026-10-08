# Git Worktree `.git` File Breaks Git Inside Containers

**HARD RULE:** A git worktree's `.git` is a *file* (not a directory) containing `gitdir: /absolute/host/path/.git/worktrees/...`. Inside a container the host path is a dangling reference → `git rev-parse --git-dir` fails with `fatal: not a git repository`, aborting any git-aware tooling (pre-commit hooks, `common.bash` git guards, `bin/check`).

Before mounting a worktree into a container, materialize a standalone repo and mount that instead:

```bash
TMP="$HOME/.cache/docker-worktree-$$"
cp -a "$PWD" "$TMP" && rm -f "$TMP/.git"
git -C "$TMP" init -q && git -C "$TMP" add -A && git -C "$TMP" commit -qm test
# mount $TMP as the Docker source; clean up after the run
```

- Never mount the live worktree directory directly when the container runs git.
- Clean up the temp repo after the run.
