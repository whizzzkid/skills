---
skill: wk-devcontainer
date: 2026-07-22
type: gap
severity: high
---

Documented teardown/rebuild commands must pin the Compose project name devcontainer up creates, or they no-op and leave the stack running.

**What happened:** A documented shutdown command "docker compose -f .devcontainer/docker-compose.yml down" targeted an empty project and silently left all containers running. `devcontainer up` (and the VS Code "Reopen in Container" flow) create the stack under project "<workspace-folder-basename>_devcontainer", but a bare -f-only invocation defaults the project to the compose file's parent directory basename ("devcontainer").

**Root cause:** Docker Compose derives the project name from the invocation; `devcontainer`/VS Code and a bare `docker compose -f` derive it differently, so teardown docs written against the bare form miss the real project.

**Suggested fix:** In any devcontainer teardown/rebuild command the skill emits, pin -p "$(basename "$PWD")_devcontainer" (or the workspace-folder basename equivalent) and note the mismatch, so `down`/`down -v`/`build` hit the running stack.
