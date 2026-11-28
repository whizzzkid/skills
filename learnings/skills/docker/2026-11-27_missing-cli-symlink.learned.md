---
skill: wk-docker
date: 2026-11-27
type: surprise
severity: medium
verified-against-source: yes
---

Package manager reports the docker CLI installed, but its bin symlink is absent, so `docker` is "command not found".

**What happened:** `docker` was not on PATH although the package manager listed the formula as installed and the
binary existed in the formula's keg directory. Only sibling helpers (`docker-compose`, credential helpers) were linked.

**Root cause:** The formula's bin symlink was missing (unlinked keg); confirmed by listing the keg bin dir and the
prefix bin dir.

**Suggested fix:** On "command not found: docker", check the keg path before any install. Prefer a non-mutating
workaround — prepend the keg's `bin` to PATH for the one command (`PATH="<keg>/bin:$PATH" devcontainer up ...`) — and
tell the user that relinking the formula is the permanent fix.
