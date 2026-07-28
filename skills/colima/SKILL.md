---
name: wk-colima
description: >-
  Use whenever working with Colima or Docker — ensures Colima is running before
  any container operation, starts it with the correct resource profile when not,
  and restarts it cleanly (full shutdown first) when Colima or Docker is
  misbehaving. Auto-invoked when any docker or colima command is about to run.
argument-hint: '[start|stop|restart|status]'
allowed-tools:
  - "Bash(colima status:*)"
  - "Bash(colima start:*)"
  - "Bash(colima stop:*)"
  - "Bash(colima delete:*)"
  - "Bash(docker info:*)"
  - "Bash(docker ps:*)"
  - "Bash(nproc:*)"
  - "Bash(sysctl -n hw.logicalcpu:*)"
model: haiku
effort: low
model-invocable: true
user-invocable: true
license: MIT
group: tools
metadata:
  author: whizzzkid
  version: "2026.07.28-171034"
  internal: false
  model:
    openai: gpt-5.6-luna
    google: gemini-2.5-flash-8b
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Colima

Ensure Colima is running and healthy before any container operation. Handles
startup with the correct resource profile and provides a clean restart path for
when Colima or Docker misbehaves.

## When to Use

Auto-invoked before any `docker` or `colima` command in the session. Also
triggered by:

- `colima start`, `colima stop`, `colima restart`, `colima status` invocations
- Docker daemon errors (`Cannot connect to the Docker daemon`, `Error response from daemon`)
- Docker socket missing or unresponsive
- Container build, run, or compose failures where the daemon is the suspect
- Explicit `/wk-colima` call

## Step 1: Check status

```bash
colima status 2>&1
```

- If output contains `Running` — Colima is healthy. Proceed; skip Steps 2–3.
- If output contains `Stopped`, `not found`, or any error — go to Step 2.
- If Colima itself is not installed, stop and report: `colima` must be
  installed (`brew install colima`).

## Step 2: Compute the CPU limit

Determine the available logical CPU count and halve it (floor):

```bash
PROC=$(nproc 2>/dev/null || sysctl -n hw.logicalcpu 2>/dev/null || echo 8)
CPU=$(( PROC / 2 ))
[ "$CPU" -lt 1 ] && CPU=1
echo "Starting colima with CPU=$CPU / 16 GB / 100 GB"
```

The halved value prevents Colima from monopolizing the host. The fixed memory
(16 GB) and disk (100 GB) values are constants; do not recalculate them.

## Step 3: Start Colima

```bash
colima start --cpu "$CPU" --memory 16 --disk 100 --mount-inotify --very-verbose
```

Wait for the command to exit. A zero exit code means Colima started
successfully. Confirm Docker is reachable:

```bash
docker info > /dev/null 2>&1 && echo "Docker OK" || echo "Docker not reachable"
```

If `docker info` fails after a successful `colima start`, proceed to the
restart sequence (Step 4).

## Step 4: Restart sequence (Colima or Docker is broken)

Use this path when:

- `colima start` exits non-zero
- Docker is unresponsive after a start
- Any Docker command returns `Cannot connect to the Docker daemon` or
  `Error response from daemon` during an otherwise normal session
- The user says "colima is broken", "restart colima", or "docker isn't working"

**Full shutdown first — never skip this step.**

```bash
# 1. Stop containers gracefully (best-effort — don't block on failure)
docker ps -q 2>/dev/null | xargs -r docker stop 2>/dev/null || true

# 2. Hard-stop Colima
colima stop --force 2>/dev/null || true

# 3. Wait for shutdown (socket may linger)
sleep 3

# 4. Start fresh
PROC=$(nproc 2>/dev/null || sysctl -n hw.logicalcpu 2>/dev/null || echo 8)
CPU=$(( PROC / 2 ))
[ "$CPU" -lt 1 ] && CPU=1
colima start --cpu "$CPU" --memory 16 --disk 100 --mount-inotify --very-verbose
```

After restart, re-run `docker info` to confirm the daemon is reachable. If the
restart sequence fails twice consecutively, report the full `colima start`
output to the user — there may be a VM-level issue requiring manual intervention
(e.g., `colima delete` to wipe state and start from scratch).

## Step 5: Report state

After any start or restart, emit a one-line status:

> "Colima running: CPU={n}, memory=16 GB, disk=100 GB. Docker reachable."

If Colima was already running (Step 1 found it healthy), emit nothing — silent
is correct when there is nothing to do.

## Quick Reference

| Trigger | Action |
|---------|--------|
| `colima status` is Stopped / error | Steps 2–3: start with dynamic CPU |
| Docker daemon unreachable | Step 4: full shutdown → start |
| Explicit `/wk-colima restart` | Step 4 unconditionally |
| Explicit `/wk-colima start` | Steps 1–3 (starts only if not running) |
| Explicit `/wk-colima stop` | `colima stop` only |
| Explicit `/wk-colima status` | Step 1 only — report and exit |

## Requirements

- `colima` installed (`brew install colima`)
- `docker` CLI installed (`brew install docker`)
- `nproc` or `sysctl` available to detect CPU count (macOS: `sysctl` is the fallback)

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn colima`).
