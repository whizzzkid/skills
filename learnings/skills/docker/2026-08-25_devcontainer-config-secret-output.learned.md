---
skill: wk-docker
date: 2026-08-25
type: gap
severity: high
verified-against-source: yes
---

Devcontainer startup output can expose forwarded secrets through resolved Compose configuration.

**What happened:** A devcontainer startup command streamed its generated Compose configuration, including the value
of a forwarded credential, into the agent-visible command log.

**Root cause:** The CLI logs the resolved Compose configuration during startup, so inherited secret environment
variables become plain-text command output even when the command itself does not mention their values.

**Suggested fix:** Require output redaction or suppression around devcontainer provisioning whenever Compose forwards
credentials, and warn that ordinary startup verbosity is unsafe for agent-visible logs.
