---
skill: wk-docker
date: 2026-08-13
type: gap
severity: medium
verified-against-source: yes
---

`devcontainer up`/`docker compose up` fails with a host-port bind conflict when another worktree's devcontainer already holds that port; no documented fallback exists that avoids touching the other worktree's running stack.

**What happened:** Starting a devcontainer for local verification failed with `Bind for 127.0.0.1:<port> failed: port is already allocated` because a sibling worktree's devcontainer for the same project was already running and bound to the default port. A docker-compose port-override file did not take effect when passed as an extra `-f` layer.

**Root cause:** `docker compose up`/`run` for a project whose compose file publishes a fixed host port cannot start a second instance on the same host without either stopping the first instance or remapping the port; an ad hoc port-override compose file did not merge as expected in this attempt (unverified — inferred from symptom, mechanism not confirmed).

**Suggested fix:** When a host-port bind conflict comes from a different worktree's own devcontainer stack that should stay running, skip `docker compose up`/`run` entirely and instead `docker run` directly against the project's already-created Docker network and named volumes (found via `docker network ls`/`docker volume ls` matching the project prefix), publishing no host port. This gets a working shell/exec target for local verification (bundle install, test/lint runs) without stopping or restarting the other worktree's containers.
