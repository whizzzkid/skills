# wk-colima

Ensures Colima is running before any container operation and provides a clean
restart path when Colima or Docker misbehaves.

**Version:** `2026.08.18-184219`

## Trigger

Auto-invoked before any `docker` or `colima` command. Also triggers on Docker
daemon errors (`Cannot connect to the Docker daemon`, `Error response from
daemon`) and on explicit `/wk-colima [start|stop|restart|status]`.

## Key Behavior

- **Status check first** — if Colima is already running, exits silently.
- **Mise-managed** — colima installs via `mise use -g colima@latest`; every
  `colima`/`docker` command runs through `mise exec --` so mise-pinned tools and
  their dependencies are on PATH.
- **Dynamic CPU & memory** — computes `floor(nproc / 2)` and derives memory from
  the host (`sysctl -n hw.memsize`, halved, floored at 1 GB) so Colima never
  exceeds the host's `maximumAllowedMemorySize`. Disk (100 GB) is fixed.
- **Socket from context** — resolves the Docker socket via `docker context ls`;
  a mise-managed colima serves under `$HOME/.config/colima/`, not `$HOME/.colima/`.
- **Restart = full shutdown first** — `colima stop --force` before any
  re-start; partial restarts leave the VM in an inconsistent state.
- **Contradictory state = stale state** — when start says running but status or
  Docker disagrees, use the forced-stop restart instead of retrying start.
- **Docker health gate** — after start, confirms `docker info` responds before
  declaring success.

## Integrations

- Used by [wk-docker](../docker/README.md) as the VM pre-flight before any
  Docker build or run.
- Invoked automatically whenever a skill or workflow attempts a `docker`
  command and the daemon is absent.
