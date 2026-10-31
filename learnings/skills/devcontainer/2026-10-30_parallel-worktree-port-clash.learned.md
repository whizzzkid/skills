---
skill: wk-devcontainer
date: 2026-10-30
type: gap
severity: medium
verified-against-source: yes
---

A second worktree's devcontainer fails `up` when another worktree's stack already binds the app's host port.

**What happened:** `devcontainer up` built the image but failed at compose up with "Bind for 127.0.0.1:3000 failed:
port is already allocated", because a sibling worktree's stack was running. Starting the stack by hand with a compose
override (`ports: !reset []`) worked for tests, but repo hooks that call `devcontainer exec` then failed with "Dev
container not found".

**Root cause:** The devcontainer CLI finds its container by the labels `devcontainer.local_folder` and
`devcontainer.config_file`. A hand-started compose container has neither label.

**Suggested fix:** On a host-port clash, start the stack with an override file that resets `ports` and adds both
labels (local_folder = workspace path, config_file = its `.devcontainer/devcontainer.json`), then run the
post-create steps manually. `devcontainer exec` and the hooks then find it. Never stop the other worktree's stack.
