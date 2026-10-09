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
  version: "2026.10.09-171327"
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# Docker

Workflows and safety checks for Docker — image building, tag verification,
container inspection, daemon troubleshooting.

## Pre-Flight Checks

- **CLI on PATH (macOS):** `command -v docker >/dev/null 2>&1 || brew link docker`
  Prepend `PATH="/opt/homebrew/bin:$PATH"` in Bash invocations.
- **Daemon:** `docker info > /dev/null 2>&1 || echo "DAEMON_NOT_RUNNING"` →
  tell user to start Docker Desktop or `colima start`. Never start it yourself.
- **Registry auth:** `authorization failed` / `ExpiredToken` → tell user: `aws sso login`.

## Image Tag Verification

**HARD RULE:** Verify an image tag exists before using it in any `FROM` directive:

```bash
docker manifest inspect <image>:<tag> 2>&1
```

`no such manifest` → try `v` prefix / without patch version; report the correct tag
to the user before using it.

Check unfamiliar base OS: `docker run --rm --entrypoint cat <image>:<tag> /etc/os-release`
(Debian → `apt-get`; Alpine → `apk`).

## `docker compose run` Env Inheritance

`docker compose run` does NOT inherit service-level `environment:` — pass
`-e VAR=value` explicitly:

```bash
docker compose run --rm -T -e RAILS_ENV=test app bundle exec rspec ...
```

## ENTRYPOINT Awareness

Custom ENTRYPOINT turns `sh -c '...'` into `custom-tool sh -c '...'` → add
`ENTRYPOINT []` after installing tools. Verify: `docker run --rm <image> sh -c 'echo works'`.

Before editing `entrypoint.*`/`run.*`/`start.*`, confirm the Dockerfile actually
invokes it: `grep -E '^(ENTRYPOINT|CMD)' Dockerfile`. Compiled-binary repos keep
same-named shell scripts for local-dev only.

## Declare Runtime Env Vars in the Dockerfile

Every env var the entrypoint reads must be declared with `ENV VAR=""` before
`ENTRYPOINT`/`USER`. Grep Dockerfile when wiring a new var; if absent, add to a
grouped block near the bottom of the build stage.

## Audit Runtime Env Reads Against the Forwarding List

**HARD RULE:** Compose/plugins forward only explicitly listed vars — unlisted vars
are silently absent. Audit the full runtime read set, not just vars the diff added: grep the runtime call graph for env reads (`ENV[`,
`ENV.fetch`, `os.environ`, `process.env`, `$VAR`), diff against the forwarding
list, flag gaps. Cross-check sibling compose files. Never use a host-side SHA as
proxy for a target-artifact SHA inside the container.

## Reference Pointers

- **Bind-mount overlay shadows COPY:** [references/bind-mount-overlay.md](references/bind-mount-overlay.md)
- **Worktree `.git` file breaks git in containers:** [references/git-worktree-gitfile.md](references/git-worktree-gitfile.md)
- **Seed dependency volume from sibling:** [references/seed-dependency-volume.md](references/seed-dependency-volume.md)
- **Multi-worktree port conflicts:** [references/port-conflicts.md](references/port-conflicts.md)

## Devcontainer Startup — Suppress Secret Exposure

**HARD RULE:** Startup commands log resolved config including secrets. Suppress
verbose output (`--log-level error`) when Compose forwards credentials. Never
run `docker compose config` in agent-visible output with secrets.

## Hand-Started Containers: Replicate Setup-Script Credentials

Private-registry auth failure in manual `docker run` → grep setup script for
exact env var name/format. Generic `<REGISTRY>_API_KEY` is almost never correct.

## Bind-Mount Permission Fixes — Scoped, Never Recursive

**HARD RULE:** Never `chmod -R` a git tree or any path in a persistent/shared host
checkout for container EACCES. Grant write
only on exact needed files/dirs. Prefer `chown <container-uid>` or a scratch
dir outside the checkout. Recursive perms on `.git/` is a red flag.

## Debugging Build Failures

- Read full error output; check the failing `RUN` interactively from the previous layer.
- Verify `COPY` sources exist; check `COPY --from=<stage>` references.
- **HARD RULE:** A `RUN` step failing with a network/fetch error in dind → check the
  stage's floating `FROM` tag before `--network=host`. Pin to the tool-version file's
  version; `--network=host` masks the cause.

### Common Exit Codes

| Exit Code | Meaning |
|-----------|---------|
| 1 | General error |
| 17 | Build failed (pull/build step) |
| 125 | Daemon error |
| 127 | Command not found |
| 137 | OOM killed |
| 139 | Segfault |

---

## Post-Completion

Invoke `wk-learn docker`.
