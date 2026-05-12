---
date: 2026-05-12
slug: host-config-mounts-and-autostart
---

- **Rule:** Mount host `~/.config/mise/config.toml` read-only and `~/.claude` read-write into the container; auto-start the app server via `postStartCommand` with `nohup` and logs under the workspace mount.
- **Why:** Inherits developer's mise plugins/settings and Claude Code memory, eliminates per-developer container drift, removes the manual "now run the server" step on every connect, and keeps logs reachable from the host without a second volume.
- **Where:** Step 3 docker-compose volumes; Step 4 devcontainer.json `postStartCommand` + `portsAttributes` + "Log paths" sub-section.
