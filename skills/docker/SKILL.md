---
name: wk:docker
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
  # Learning capture (post-completion hook)
  - Write
  - "Bash(mkdir -p:*)"
model: sonnet
effort: medium
model-invocable: true
user-invocable: true
license: MIT
metadata:
  author: whizzzkid
  version: '1.0.0'
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

**Known issue:** `jdxcode/mise` sets `ENTRYPOINT ["mise"]`, which causes
`docker-compose run <service> sh -c '...'` to become `mise sh -c '...'`,
breaking all commands.

**Fix:** Add `ENTRYPOINT []` in the Dockerfile after installing tools to
reset the entrypoint. Verify with:

```bash
docker run --rm <image> sh -c 'echo works'
```

If the output shows an error about unknown commands or arguments, the
ENTRYPOINT needs to be reset.

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

## Post-Completion: Learning Capture

**After this skill finishes its primary work**, capture what happened
before returning control.

### Check environment

```bash
test -n "$WK_SKILLS_HOME" && echo "OK: $WK_SKILLS_HOME" || echo "MISSING"
```

If `$WK_SKILLS_HOME` is not set, ask the user:

> "`$WK_SKILLS_HOME` is not set. Please add
> `export WK_SKILLS_HOME=/path/to/skills` to your shell profile and
> restart your terminal."

**Stop here if the variable is missing.** Do not guess or use a fallback.

### Reflect

Review what happened during this skill's execution:

1. **What went wrong?** — Errors, wrong assumptions, user corrections,
   API failures, unexpected behavior
2. **What was missing?** — Steps the skill should have included, edge
   cases not covered, tools not available
3. **What worked well?** — Approaches that succeeded, patterns worth
   reinforcing
4. **What surprised you?** — Non-obvious discoveries that future runs
   should know about

If ALL lenses are empty (routine execution, nothing notable), **skip
writing** — not every run produces a learning.

### Write the learning

```bash
mkdir -p "$WK_SKILLS_HOME/learnings/skills/docker"
```

Write to
`$WK_SKILLS_HOME/learnings/skills/docker/<YYYY-MM-DD>_<learning-slug>.md`:

```markdown
---
skill: wk:docker
date: <YYYY-MM-DD>
type: <correction | gap | pattern | surprise>
severity: <low | medium | high>
---

<One-line summary>

**What happened:** <What the skill did or failed to do>

**Root cause:** <Why — missing instruction, wrong assumption, edge case>

**Suggested fix:** <What should change in the skill to prevent this>
```

Use a 2-4 word kebab-case slug (e.g., `missing-null-check`,
`wrong-api-endpoint`, `good-parallel-pattern`).

### Signal for distillation

After writing, note:

> "📝 Learning captured: `docker/<date>_<slug>.md` — distill with
> `wk:sharpen` when ready."

Learnings accumulate in `$WK_SKILLS_HOME/learnings/skills/` and are
batch-distilled into skill improvements via `wk:sharpen`.
