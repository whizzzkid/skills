---
class: principle
---

# Environment guardrails

- **AWS / ECR:** On auth or credential errors, prompt for `aws sso login`; do
  not retry without valid credentials.
- **Docker:** On daemon or socket errors, prompt for Docker Desktop or Colima;
  use [`wk-docker`](../../docker/README.md).
- **Devcontainer-first:** Prefer a runnable `.devcontainer/` over host-native
  runners. Probe before selecting a toolchain; on host failure, check the
  containerized alternative before repairing the host. Missing documentation
  does not prove the workflow is absent.
- **Configuration:** Add permission rules, settings, and MCP servers to
  `$HOME/.claude/settings.json`, not `.claude/settings.local.json`, unless
  intentionally local. Use `--scope user` for MCP servers. Never add MCPs to
  `$HOME/.claude.json`.
- **CI:** Use [`wk-buildkite`](../../buildkite/README.md) for Buildkite; read
  actual logs, never guess.
