# Multi-Worktree Port Conflicts

When `docker compose up` / `devcontainer up` fails with `port is already allocated` because a sibling worktree's container holds the default port:

- Skip `docker compose up/run` — port-override compose layers are fragile and may not merge as expected.
- Use `docker run` with `--network=<project-network>` and named volume mounts, publishing no host port (`-p` omitted). Find the project's network and volumes via `docker network ls` / `docker volume ls` matching the project prefix.
- This gives a working shell for local verification (test, lint) without stopping or restarting the sibling worktree's stack.
- Never stop a running sibling's devcontainer to resolve a port conflict.
