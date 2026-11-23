---
skill: wk-devcontainer
date: 2026-11-20
type: gap
severity: low
verified-against-source: yes
---

`docker compose -p "$(basename "$PWD")_devcontainer" down` fails when the worktree basename has uppercase letters.

**What happened:** The documented shutdown command errored with "invalid project name"; the devcontainer CLI had created the project with a lowercased name.

**Root cause:** Compose project names must be lowercase; the devcontainer CLI lowercases the folder name, the documented command does not.

**Suggested fix:** Derive the project name from running containers (`docker ps --format '{{.Label "com.docker.compose.project"}}'`) or lowercase it: `-p "$(basename "$PWD" | tr '[:upper:]' '[:lower:]')_devcontainer"`.
