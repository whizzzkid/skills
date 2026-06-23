---
skill: wk-docker
date: 2026-06-23
type: surprise
severity: high
---

Git worktrees use a `.git` file (not directory) that breaks `git` commands inside Docker containers.

**What happened:** Running `bin/check` from a git worktree failed inside Docker with `fatal: not a git repository`. The worktree's `.git` is a plain file containing `gitdir: /absolute/host/path/.git/worktrees/...`, which the container cannot resolve.

**Root cause:** Docker containers don't mount the host's full filesystem, so absolute paths inside `.git` worktree pointer files are dangling references inside the container. `git rev-parse --git-dir` fails, and any `git`-aware tooling (pre-commit hooks, common.bash git guards) aborts.

**Suggested fix:** Before mounting a worktree directory into a Docker container, copy it to a `$HOME`-based temp path, remove the `.git` file, and run `git init -q && git add -A && git commit -q -m "test"` to create a standalone repo. Use the temp path as the Docker mount source. Clean up after the run.
