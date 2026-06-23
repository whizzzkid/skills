---
class: principle
skill: wk-docker
date: 2026-06-23
---

**Rule**

Before mounting a git worktree into a container that runs git, materialize a
standalone repo (copy out, `rm .git`, `git init && add && commit`) and mount that
instead. Never mount the live worktree directory directly.

**Why**

A worktree's `.git` is a *file* containing `gitdir: /absolute/host/path/...`.
Inside the container that host path is dangling → `git rev-parse --git-dir`
fails with `fatal: not a git repository`, aborting pre-commit hooks and any
git-aware tooling (`bin/check`, `common.bash` guards).

**Where**

New "Git Worktree `.git` File Breaks Git Inside Containers" HARD RULE section.
