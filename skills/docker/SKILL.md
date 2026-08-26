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
  version: "2026.08.26-175806"
  model:
    openai: gpt-5.6-terra
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

### Docker CLI on PATH (macOS)

`docker: command not found` on macOS despite a Homebrew install → the
`/opt/homebrew/bin/docker` symlink was dropped on a package upgrade (binary
still in the Cellar). Bash-tool sessions also may not inherit the full PATH.

```bash
command -v docker >/dev/null 2>&1 || brew link docker
```

- Prepend Homebrew's bin to PATH in macOS Bash invocations: `PATH="/opt/homebrew/bin:$PATH"`.
- Run `brew link docker` before any retry when the binary is missing.

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

## `docker compose run` Env Inheritance

`docker compose run` does NOT inherit service-level `environment:` from
`docker-compose.yml` — it uses the container's own defaults. Always pass
`-e RAILS_ENV=test` (or equivalent) when running specs via `run` instead
of `exec` on a running service.

```bash
docker compose run --rm -T -e RAILS_ENV=test app bundle exec rspec ...
```

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

## Git Worktree `.git` File Breaks Git Inside Containers

**HARD RULE:** A git worktree's `.git` is a *file* (not a directory) containing
`gitdir: /absolute/host/path/.git/worktrees/...`. Inside a container the host
path is a dangling reference → `git rev-parse --git-dir` fails with
`fatal: not a git repository`, aborting any git-aware tooling (pre-commit hooks,
`common.bash` git guards, `bin/check`).

Before mounting a worktree into a container, materialize a standalone repo and
mount that instead:

```bash
TMP="$HOME/.cache/docker-worktree-$$"
cp -a "$PWD" "$TMP" && rm -f "$TMP/.git"
git -C "$TMP" init -q && git -C "$TMP" add -A && git -C "$TMP" commit -qm test
# mount $TMP as the Docker source; clean up after the run
```

- Never mount the live worktree directory directly when the container runs git.
- Clean up the temp repo after the run.

## Seed a Dependency Volume from a Sibling

An expired package-registry credential is not a hard stop for a fresh container.
A provisioning script typically treats the registry as the *only* source of
dependencies, so a 401 on index fetch blocks setup entirely — even when every needed
artifact already sits in a sibling container's volume on the same daemon.

Copy the volume with a throwaway container mounting both, then install offline:

```bash
docker volume ls          # confirm BOTH endpoints exist before copying
docker run --rm -v "$SRC_VOL":/from -v "$DST_VOL":/to alpine:3.21 \
  sh -c 'cp -a /from/. /to/ && du -sh /to'
```

Then, inside the target container, resolve entirely from the seeded cache —
`bundle install --local`, or the ecosystem's offline / frozen-cache equivalent.

Two guards:

- **Seed only from the same lockfile generation.** The offline install then fails
  loudly on a missing version instead of silently resolving a stale one.
- **Verify both volume names before copying.** Names are project-prefixed
  (`<project>_<volume>`), so a mistyped destination silently creates a new empty
  volume and the copy "succeeds" into nothing.

## Devcontainer Startup — Suppress Secret Exposure

**HARD RULE:** Devcontainer and Compose startup commands log the resolved
configuration as plain text, including forwarded secret env vars. Suppress
verbose startup output (`--log-level error`, stdout redirect) when Compose
forwards credentials — ordinary startup verbosity is unsafe for agent-visible
logs.

- Never run `docker compose config` or equivalent in agent-visible output when
  the config forwards secrets.
- Treat any startup log that resolves env vars as potentially containing
  credentials.

## Multi-Worktree Port Conflicts

When `docker compose up` / `devcontainer up` fails with `port is already
allocated` because a sibling worktree's container holds the default port:

- Skip `docker compose up/run` — port-override compose layers are fragile and
  may not merge as expected.
- Use `docker run` with `--network=<project-network>` and named volume mounts,
  publishing no host port (`-p` omitted). Find the project's network and volumes
  via `docker network ls` / `docker volume ls` matching the project prefix.
- This gives a working shell for local verification (test, lint) without
  stopping or restarting the sibling worktree's stack.
- Never stop a running sibling's devcontainer to resolve a port conflict.

## Hand-Started Containers: Replicate Setup-Script Credentials

When running a container manually (`docker run`, not via the project's setup
script), private-registry auth failures often mean the wrong env var name —
package managers use tool-specific credential naming, not a generic API key.

- Grep the project's setup/provisioning script for how it exports registry
  credentials — replicate the exact env var name and value format.
- A generic `<REGISTRY>_API_KEY` is almost never what the package manager reads.

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

### dind Network Failures — Check Floating Tags Before `--network=host`

**HARD RULE:** When a `RUN` step inside `docker build` fails with a network or
fetch error in a docker-in-docker (dind) environment, check the stage's `FROM`
tag before reaching for `--network=host`.

- A floating base tag (`rust:bookworm`, `node:slim`, `:latest`) that updated
  upstream invalidates the layer cache, forcing the `RUN` to execute cold — and
  the cold run needs external network the dind bridge network lacks.
- Pin the tag to match the project's tool-version file (`mise.toml`,
  `.tool-versions`): `rust:bookworm` → `rust:1.93-bookworm`. A stable cache means
  the `RUN` never runs cold inside dind.
- `--network=host` masks the real cause; reserve it for when pinning is impossible
  or the failure is not cache-related.

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
