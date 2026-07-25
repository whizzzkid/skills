# wk-workstyle-shell

> Enforces safe, idiomatic shell-script conventions on every shell file the agent writes or edits.

**Version:** `2026.07.24-235129`

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
- One-line comment above each function (scripts with ≥3 functions) — describe what it does and any non-obvious output format.
- No `${VAR:?msg}` guard when an `EXIT` trap is registered — bash 3.2 resets `$?` to 0 on `:?` failure; use an explicit `if [[ -z … ]]; then exit 1; fi`.
- Probe capability, don't parse error text — branch on exit code against a known-good input, since stderr wording differs across GNU/BSD/BusyBox and fails closed on the variant it was meant to handle.
- Never `sed -i` for an in-place edit — BSD/macOS reads the script as the required backup suffix; use `perl -pi -e 's{a}{b};' file`, which behaves identically on both platforms.
- Presence-check with a test builtin, never a value expansion — `${VAR:-NO}` emits the value on the set path, so a `${VAR:+yes}${VAR:-NO}` "boolean" leaks a live secret; fingerprint with length + hash prefix when a value must be compared.
- Keep documented snippets portable to zsh as well as bash — `for x in $LIST` does not split under zsh (body runs once over the whole blob) and `${!var}` aborts as `bad substitution`; use a `while IFS= read -r` loop and `printenv` exit status.

## Noteworthy

- **Project config is always authoritative.** Defers to any active linter /
  formatter config; fills gaps only.
- **Part of the [`wk-workstyle`](../workstyle/README.md) family** — the [`wk-workstyle`](../workstyle/README.md) orchestrator runs
  the shared project-style-authority probe (Step 0) and routes to this skill
  based on the touched files / change type. This skill is also independently
  model-invocable on adjacent work.
- **GNU is not the portable default.** Every rule here that names a vendor exists because
  the GNU spelling fails silently or destructively on BSD/macOS — option reordering,
  `sed -i`, stderr wording. Write the form that works on both rather than branching.
- `set -euo pipefail`, quoted variables, and `local`-scoped function vars are baseline; `[[ ]]` over `[ ]` in bash.
