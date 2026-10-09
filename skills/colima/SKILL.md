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
  - "Bash(docker context ls:*)"
  - "Bash(nproc:*)"
  - "Bash(sysctl -n hw.logicalcpu:*)"
  - "Bash(sysctl -n hw.memsize:*)"
  - "Bash(mise exec:*)"
  - "Bash(mise use:*)"
model: haiku
effort: low
model-invocable: true
user-invocable: true
license: MIT
group: tools
metadata:
  author: whizzzkid
  version: "2026.10.09-184159"
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

Ensure Colima is running and healthy before any `docker` or `colima` command. Also run on `colima
start|stop|restart|status`, Docker daemon errors (`Cannot connect to the Docker daemon`, `Error response from
daemon`), a missing/unresponsive Docker socket, or build/run/compose failures where the daemon is the suspect.
Requires `colima` via mise (`mise use -g colima@latest`; Lima installs alongside it, not as a separate package), the
`docker` CLI, and `nproc` or `sysctl` (macOS fallback).

Explicit `/wk-colima`: `status` → Step 1 only, report and exit; `start` → Steps 1–3; `stop` → `colima stop` only;
`restart` → Step 4 unconditionally.

## Step 1: Check status

```bash
mise exec -- colima status 2>&1
```

Take the first that matches: 1) `colima` not installed → stop and report it must be installed
(`mise use -g colima@latest`); 2) `Running` → healthy, proceed, skip Steps 2–3; 3) `Stopped`, `not found`, or any
error → Step 2.

## Step 2: Compute CPU and memory limits

Derive CPU and memory from the host and halve both (floor). Never hardcode memory — the VZ driver rejects requests
above the host's `maximumAllowedMemorySize`. Disk (100 GB) stays constant.

```bash
PROC=$(nproc 2>/dev/null || sysctl -n hw.logicalcpu 2>/dev/null || echo 8)
CPU=$(( PROC / 2 ))
[ "$CPU" -lt 1 ] && CPU=1
MEM_BYTES=$(sysctl -n hw.memsize 2>/dev/null || echo 17179869184)
MEM_GB=$(( MEM_BYTES / 1073741824 / 2 ))
[ "$MEM_GB" -lt 1 ] && MEM_GB=1
echo "Starting colima with CPU=$CPU / ${MEM_GB} GB / 100 GB"
```

## Step 3: Start Colima

```bash
mise exec -- colima start --cpu "$CPU" --memory "$MEM_GB" --disk 100 --mount-inotify --very-verbose
```

Wait for exit; zero means started. Confirm Docker is reachable — resolve the socket from `docker context ls`, never
assume `$HOME/.colima/` (a mise-managed colima serves under `$HOME/.config/colima/`):

```bash
docker context ls
docker info > /dev/null 2>&1 && echo "Docker OK" || echo "Docker not reachable"
```

**Important:** `colima start` claims the VM is already running while `colima status` or `docker info` disagrees →
treat runtime state as stale and go to the forced-stop restart sequence (Step 4); do not retry start in place.

## Step 4: Restart sequence (Colima or Docker is broken)

Use when `colima start` exits non-zero, Docker is unresponsive after a start, any Docker command returns `Cannot
connect to the Docker daemon` or `Error response from daemon` during an otherwise normal session, or the user says
"colima is broken", "restart colima", or "docker isn't working". **Full shutdown first — never skip this step.**

```bash
# 1. Stop containers gracefully (best-effort — don't block on failure)
docker ps -q 2>/dev/null | xargs -r docker stop 2>/dev/null || true

# 2. Hard-stop Colima
mise exec -- colima stop --force 2>/dev/null || true

# 3. Wait for shutdown (socket may linger)
sleep 3

# 4. Start fresh
PROC=$(nproc 2>/dev/null || sysctl -n hw.logicalcpu 2>/dev/null || echo 8)
CPU=$(( PROC / 2 ))
[ "$CPU" -lt 1 ] && CPU=1
MEM_BYTES=$(sysctl -n hw.memsize 2>/dev/null || echo 17179869184)
MEM_GB=$(( MEM_BYTES / 1073741824 / 2 ))
[ "$MEM_GB" -lt 1 ] && MEM_GB=1
mise exec -- colima start --cpu "$CPU" --memory "$MEM_GB" --disk 100 --mount-inotify --very-verbose
```

After restart, re-run `docker info` to confirm the daemon is reachable. Restart sequence fails twice consecutively →
report the full `colima start` output to the user; a VM-level issue may need manual intervention (e.g., `colima
delete` to wipe state and start from scratch).

## Step 5: Report state

After any start or restart, emit: "Colima running: CPU={n}, memory={m} GB, disk=100 GB. Docker reachable." Step 1
found it healthy → emit nothing.

## Post-Completion

Invoke `wk-learn colima`.
