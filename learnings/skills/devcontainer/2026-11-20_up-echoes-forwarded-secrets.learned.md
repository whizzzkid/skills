---
skill: wk-devcontainer
date: 2026-11-20
type: surprise
severity: medium
verified-against-source: yes
---

`devcontainer up` prints the resolved compose config, echoing forwarded secret env values into tool output.

**What happened:** The devcontainer CLI logged `docker compose ... config` output at startup, including the literal
value of a registry API key forwarded via `environment: KEY: ${KEY:-}`. The output landed in a persisted
tool-result file.

**Root cause:** The CLI runs `compose config` to resolve services and logs its full stdout, which interpolates
host env values.

**Suggested fix:** Run `devcontainer up ... 2>&1 | tail -n 5` (the final JSON line carries the outcome and compose
project name), or redirect to a temp file and read only the tail. If the full output was captured, tell the user a
secret was written to local tool output.
