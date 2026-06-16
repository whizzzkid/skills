---
name: wk-docker
description: >-
  Use when working with Docker — building images, inspecting containers,
  debugging Dockerfile issues, verifying image tags exist, or troubleshooting
  Docker daemon connectivity. Activates on Docker-related errors, Dockerfile
  edits, or docker-compose operations.
allowed-tools:
  # Read-only Docker commands
  - "Bash(docker info:*)"
  - "Bash(docker version:*)"
  - "Bash(docker inspect:*)"
  - "Bash(docker manifest inspect:*)"
  - "Bash(docker history:*)"
  - "Bash(docker ps:*)"
  - "Bash(docker logs:*)"
  - "Bash(docker stats:*)"
  - "Bash(docker top:*)"
  - "Bash(docker port:*)"
  - "Bash(docker diff:*)"
  - "Bash(docker images:*)"
  - "Bash(docker image ls:*)"
  - "Bash(docker compose ps:*)"
  - "Bash(docker compose config:*)"
  - "Bash(docker compose logs:*)"
  - AskUserQuestion
model: sonnet
effort: medium
model-invocable: true
user-invocable: true
license: MIT
group: tools
metadata:
  author: whizzzkid
  version: '2026.06.16-165651'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# Docker

Workflows and safety checks for Docker operations — image building, tag
verification, container inspection, and daemon troubleshooting.

## When to Use

- Building or modifying Dockerfiles
- Debugging Docker build failures or container runtime errors
- Verifying Docker image tags exist before using them
- Working with docker-compose services
- Troubleshooting Docker daemon connectivity

## Pre-Flight Checks

### Docker Daemon

Before any Docker operation, verify the daemon is running:

```bash
docker info > /dev/null 2>&1 || echo "DAEMON_NOT_RUNNING"
```

If the daemon is not running, tell the user:
> Docker daemon is not running. Start Docker Desktop or run `colima start`.

Do NOT attempt to start the daemon yourself.

### ECR / Registry Auth

If you encounter `authorization failed`, `no basic auth credentials`, or
`ExpiredToken` errors from ECR or other registries:

> AWS credentials have expired. Run `aws sso login` to refresh.

## Image Tag Verification

**HARD RULE:** Before using any Docker image tag in a Dockerfile `FROM`
directive, verify it exists:

```bash
docker manifest inspect <image>:<tag> 2>&1
```

- If the manifest exists, proceed.
- If it returns `no such manifest`, try common tag format variations:
  - With/without `v` prefix (`v1.2.3` vs `1.2.3`)
  - With/without patch version (`1.2.3` vs `1.2`)
  - Report the correct tag to the user before using it.

### Check Base OS

When using an unfamiliar base image, verify the OS to choose the right
package manager:

```bash
docker run --rm --entrypoint cat <image>:<tag> /etc/os-release 2>&1
```

- Debian/Ubuntu → `apt-get`
- Alpine → `apk`
- If the image has a custom ENTRYPOINT, use `--entrypoint cat` to bypass it.

## ENTRYPOINT Awareness

Some base images set a custom ENTRYPOINT that interferes with
docker-compose commands.

**Example:** an image that sets `ENTRYPOINT ["/custom-tool"]` turns
`docker-compose run <service> sh -c '...'` into `custom-tool sh -c '...'`,
breaking all commands.

**Fix:** Add `ENTRYPOINT []` in the Dockerfile after installing tools to
reset the entrypoint. Verify with:

```bash
docker run --rm <image> sh -c 'echo works'
```

If the output shows an error about unknown commands or arguments, the
ENTRYPOINT needs to be reset.

## Verify the ENTRYPOINT Before Editing a Wrapper Script

Before editing any script named `entrypoint.*`, `run.*`, `start.*`, or
any file whose role *looks* like a container entrypoint, confirm the
Dockerfile actually invokes it. Repos that ship a compiled binary
(Rust, Go, etc.) as the production entrypoint frequently keep a
same-named shell script for local-dev or legacy paths — editing the
shell script produces a change that passes review but never runs in
production.

```bash
grep -E '^(ENTRYPOINT|CMD)' Dockerfile
```

- The grep target — file path, binary name, or shell line — is the
  real entrypoint. Confirm the file you are about to edit matches.
- If a binary is named (e.g., `/usr/local/bin/foo`), find where it is
  built from in the repo. The companion shell script is rarely the
  production path.

## Declare Runtime Env Vars in the Dockerfile

Every environment variable the entrypoint or CMD reads at runtime
must be declared with `ENV VAR=""` (or a real default) in the
Dockerfile, before the `ENTRYPOINT` / `USER` line.

The Dockerfile is the canonical interface document for the image.
An env var that only appears in compose, CI pipeline, or orchestrator
config is invisible to anyone reading the image alone — they cannot
tell whether the var is supported, ignored, or required without
spelunking the entrypoint script.

**How to apply.** When wiring a new runtime env var, after updating
compose / pipeline allowlists, grep the Dockerfile for the var name.
If absent, add it inside a grouped `# Optional runtime env vars`
block near the bottom of the build stage:

```dockerfile
# Optional runtime env vars (defaults documented; override at run time)
ENV LOG_LEVEL=""
ENV FEATURE_FLAG_X=""
```

Use an empty string for "unset by default; entrypoint handles
absence" and a real value when there is a meaningful default. Either
way the variable name is now part of the image's documented contract.

## Audit Runtime Env Reads Against the Forwarding List

**HARD RULE:** Compose and the Buildkite `docker_compose` plugin forward
*only* the env vars explicitly listed in the `environment:` / `env:` array.
Agent-level vars — CI builtins and user-defined secrets alike — are silently
absent inside the container unless declared. A missing entry surfaces as a
runtime "feature not enabled" with no error, not a failure.

Before treating a compose/plugin config as complete, audit the full runtime
read set — not just the vars the diff added:

1. Grep every script and library in the container's runtime call graph for
   env reads: `ENV[`, `ENV.fetch`, `os.environ`, `process.env`, `$VAR`, etc.
2. Collect the full set of env var names read.
3. Diff that set against the `environment:` / `env:` list.
4. Flag any read with no corresponding forwarding entry.
5. Cross-check sibling templates/compose files serving the same role —
   inconsistency between siblings is a strong signal of a missing entry.

**Never use a host-side SHA or build identifier (e.g. the CI runner's own
commit SHA) as a proxy for a target-artifact SHA inside the container** —
they are different values and fail downstream comparisons.

## Bind-Mount Overlay Shadows Image COPY

A CI step that runs under a volume mount (`-v <checkout>:/workdir --workdir=/workdir`,
common on Buildkite agents) replaces the image filesystem at the mount point with
the live checkout. Any Dockerfile `COPY` to a path under that mount is invisible
at runtime.

**HARD RULE:** Generated artifacts a mounted step needs (Go embeds, codegen,
build output) must be produced by the step's own command, not pre-baked via
`COPY` into the overlaid path.

- Symptom: a `COPY --from=...` lands in the image, yet the step still reports the
  file missing.
- Fix: add the generator to the step command before the consumer — e.g.
  `go generate ./... && go test`.
- Never rely on `COPY /workdir/...` (or any mount-point path) reaching a step that
  overlays that path with a bind mount.

## Building Images

### docker build

```bash
# Build with specific target
docker build --target <stage> -f <Dockerfile> -t <tag> <context>

# Build with cache
docker build --cache-from <image> -t <tag> .
```

### docker-compose build

```bash
# Build specific service
docker compose -f <compose-file> build <service>

# Build and run
docker compose -f <compose-file> run --rm <service> <command>
```

## Inspecting Containers

```bash
# List running containers
docker ps

# View logs
docker logs <container> --tail 50

# Execute command in running container
docker exec -it <container> sh

# Inspect image layers
docker history <image>:<tag>
```

## Debugging Build Failures

When a Docker build fails:

1. **Read the full error output** — the actual error is often buried in build
   output
2. **Check the failing RUN command** — run it interactively in a temporary
   container from the previous layer
3. **Verify COPY sources exist** — ensure the build context contains the files
   being copied
4. **Check multi-stage references** — ensure `COPY --from=<stage>` references
   valid stages

### Common Exit Codes

| Exit Code | Meaning |
|-----------|---------|
| 1 | General error (command failed) |
| 2 | Misuse of shell command |
| 17 | Docker build failed (image pull or build step) |
| 125 | Docker daemon error |
| 126 | Command not executable |
| 127 | Command not found |
| 137 | OOM killed (SIGKILL) |
| 139 | Segfault (SIGSEGV) |

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| Dockerfile edit | Verify base image tags exist before committing |
| Build failure | Read error, check exit code, debug failing layer |
| Daemon not running | Tell user to start Docker Desktop or Colima |
| Auth failure | Tell user to run `aws sso login` |
| ENTRYPOINT issues | Check with `docker run --rm <image> sh -c 'echo test'` |

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn docker`).
