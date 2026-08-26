---
class: principle
source: learnings/skills/docker/2026-08-25_devcontainer-config-secret-output.md
---

# Devcontainer startup can expose forwarded secrets

Compose CLI logs the resolved configuration during startup. When the Compose
file forwards host env vars (e.g., `${AWS_SESSION_TOKEN}`), the resolved
values appear as plain text in command output — even when the startup command
itself never prints them.

**Impact:** An agent-visible log of a devcontainer startup leaks any
credential forwarded through the Compose environment section.

**Mitigation:** Redirect or suppress startup verbosity when credentials are
forwarded. Never run `docker compose config` where the output is
agent-visible. Treat any resolved-config log as potentially credential-bearing.
