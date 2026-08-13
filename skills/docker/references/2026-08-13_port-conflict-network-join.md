---
class: principle
---

**Rule** — When a host-port bind conflict blocks `docker compose up` / `devcontainer up`
because a sibling worktree's container already holds the default port, use `docker run`
with `--network=<project-network>` and named volumes (no `-p`), joining the existing
infrastructure without stopping the sibling.

**Why** — Stopping a sibling's stack disrupts that worktree's dev session; port-override
compose layers are fragile and may not merge as expected. Network-join sidesteps both.

**Where** — `SKILL.md` → Multi-Worktree Port Conflicts.
