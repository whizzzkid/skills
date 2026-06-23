---
class: principle
skill: wk-docker
date: 2026-06-23
---

**Rule**

`docker: command not found` on macOS despite a Homebrew install → run
`brew link docker` before any retry, and prepend `/opt/homebrew/bin` to PATH in
Bash-tool invocations.

**Why**

Homebrew can drop the `/opt/homebrew/bin/docker` symlink on a package upgrade
(binary remains in the Cellar); Bash-tool sessions also may not inherit the full
PATH.

**Where**

Pre-Flight Checks → "Docker CLI on PATH (macOS)" subsection.
