---
skill: wk-devcontainer
date: 2026-11-20
type: surprise
severity: medium
verified-against-source: yes
---

A second devcontainer stack started via raw `docker compose` + port override is invisible to `devcontainer exec`.

**What happened:** Another worktree's stack held the fixed host port, so a compose override file (outside the repo)
remapped the app port with `ports: !override`. The stack ran, but a pre-commit hook that falls back to
`devcontainer exec --workspace-folder .` failed with "Dev container not found", so agents could not commit without
skipping hooks.

**Root cause:** The devcontainer CLI locates containers by the labels `devcontainer.local_folder` and
`devcontainer.config_file`, which only `devcontainer up` sets. Verified: adding those labels in the override and
recreating the app service made `devcontainer exec` resolve it.

**Suggested fix:** When running parallel stacks, use a per-worktree override with `ports: !override` plus both
devcontainer labels set to the worktree path and its `.devcontainer/devcontainer.json`; project name
`<worktree-basename>_devcontainer` keeps volumes separate.
