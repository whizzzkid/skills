---
skill: wk-docker
date: 2026-11-27
type: surprise
severity: low
verified-against-source: yes
---

`spawn docker ENOENT` with the VM runtime up can mean the Homebrew docker CLI is installed but unlinked.

**What happened:** `devcontainer up` failed with `spawn docker ENOENT` while the container VM reported running. The
docker formula's `opt/docker/bin` held the CLI, but the Homebrew `bin/docker` link was missing, in both the agent
shell and the login shell.

**Root cause:** The formula's link into the Homebrew prefix was removed (cause not determined).

**Suggested fix:** On `docker: command not found`/`ENOENT`, check `$(brew --prefix)/opt/docker/bin` before anything
else; prepend it to PATH for the agent's own commands (no host mutation) and tell the user `brew link docker` fixes it
permanently.
