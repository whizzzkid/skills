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
  containerized alternative before repairing the host. Never install
  task-specific host packages until the container path is absent or unusable
  and the user approves the host mutation. Missing documentation does not prove
  the workflow is absent.
- **Mixed toolchains:** Before the first secondary package-manager/toolchain
  command, state its owning subsystem and documented boundary. Run its native
  check and the repository-wide primary gate; the exception replaces neither.
- **Configuration:** Add permission rules, settings, and MCP servers to
  `$HOME/.claude/settings.json`, not `.claude/settings.local.json`, unless
  intentionally local. Use `--scope user` for MCP servers. Never add MCPs to
  `$HOME/.claude.json`.
- **1Password-backed credentials (SSH signing keys, env vars):**
  - At session start, cache signing-critical values into shell env vars via
    `op read` / `op run` substitution — subsequent ops use `$VAR`, never
    re-query the vault.
  - **Never write secrets to disk** (no tmp files, no dotfiles) — process-scoped
    env vars only; 1Password's agent controls the key material.
  - **Never log, echo, or print raw secret values** in session transcripts,
    chat, or command output — access exclusively by variable substitution
    (`$SSH_SIGNING_KEY`, `$GIT_CONFIG_PARAMETERS`).
  - If 1Password is locked mid-session, prompt the user to unlock; never retry
    in a loop or fall back to unsigned operations.
- **CI:** Use [`wk-buildkite`](../../buildkite/README.md) for Buildkite; read
  actual logs, never guess.
- **Mise-managed repos:** `GemNotFound` on `bundle exec` / `bin/rspec` is a
  setup gap. Run `bin/setup`, then invoke tests via `mise exec -- <cmd>`.
