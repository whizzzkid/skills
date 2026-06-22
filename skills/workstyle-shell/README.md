# wk-workstyle-shell

> Enforces safe, idiomatic shell-script conventions on every shell file the agent writes or edits.

**Version:** `2026.06.22-175725`

## Invocation

| Mode | Trigger |
|------|---------|
| Model-invocable | Automatic whenever the agent writes or edits a `.sh` file, a bash/sh script, or a bin script with a shell shebang |
| User-invocable | `/wk-workstyle-shell scan` — full tree; `/wk-workstyle-shell check <path>` — one file |

## Rules at a Glance

- `set -euo pipefail` at the top of every script.
- Quote every variable — `"$var"` not `$var`; unquoted variables split on whitespace.
- `local` for all variables inside functions.
- `[[ … ]]` over `[ … ]` in bash.
- Heredoc for multi-line strings; avoid concatenated `echo` chains.
- Named constants for magic values at the top of the script.
- Probe capability, don't parse error text — branch on exit code against a known-good input.

## Noteworthy

- **Project config is always authoritative.** Defers to any active linter /
  formatter config; fills gaps only.
- **Part of the [`wk-workstyle`](../workstyle/README.md) family** — the [`wk-workstyle`](../workstyle/README.md) orchestrator runs
  the shared project-style-authority probe (Step 0) and routes to this skill
  based on the touched files / change type. This skill is also independently
  model-invocable on adjacent work.
- Capability-probe, don't parse error text — branch on exit code against a known-good input, since stderr wording differs across GNU/BSD/BusyBox and fails closed on the variant it was meant to handle.
- `set -euo pipefail`, quoted variables, and `local`-scoped function vars are baseline; `[[ ]]` over `[ ]` in bash.
