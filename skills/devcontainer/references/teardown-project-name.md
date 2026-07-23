---
class: principle
---

**Rule** — Every teardown/rebuild command the skill emits must pin the Compose
project name with `-p "$(basename "$PWD")_devcontainer"`.

**Why** — `devcontainer up` and VS Code "Reopen in Container" create the stack
under project `<workspace-folder-basename>_devcontainer`. A bare `docker compose
-f .devcontainer/docker-compose.yml down` defaults the project to the compose
file's parent-directory basename (`devcontainer`), so it targets an empty
project, reports success, and silently leaves the real stack running.

**Where** — "Teardown / rebuild the stack" section and the Common Mistakes row
for a clean-but-no-op `down`.
