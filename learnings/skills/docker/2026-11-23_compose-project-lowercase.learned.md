---
skill: wk-docker
date: 2026-11-23
type: surprise
severity: low
verified-against-source: yes
---

A compose `-p` project name built from `basename "$PWD"` fails when the directory name contains uppercase letters.

**What happened:** `docker compose -p "$(basename "$PWD")_devcontainer" ... down` failed with "invalid project name ...
must consist only of lowercase alphanumeric characters". The devcontainer CLI had created the stack under a lowercased
name, which its `devcontainer up` JSON output reports as `composeProjectName`.

**Root cause:** Compose project names must be lowercase. The devcontainer CLI lowercases the folder name, but a raw
`basename` does not.

**Suggested fix:** Take `-p` from `composeProjectName` in the `devcontainer up` output, or lowercase it
(`"$(basename "$PWD" | tr '[:upper:]' '[:lower:]')_devcontainer"`).
