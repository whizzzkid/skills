# wk-colima

Ensures Colima is running before any container operation and provides a clean
restart path when Colima or Docker misbehaves.

**Version:** `2026.08.05-212450`

## Trigger

Auto-invoked before any `docker` or `colima` command. Also triggers on Docker
daemon errors (`Cannot connect to the Docker daemon`, `Error response from
daemon`) and on explicit `/wk-colima [start|stop|restart|status]`.

## Key Behavior

- **Status check first** — if Colima is already running, exits silently.
- **Dynamic CPU** — computes `floor(nproc / 2)` so Colima never monopolizes
  the host. Memory (16 GB) and disk (100 GB) are fixed constants.
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
