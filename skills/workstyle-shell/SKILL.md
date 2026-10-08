---
name: wk-workstyle-shell
description: >-
  Shell scripts and compound ad-hoc commands (bash/sh/zsh) — `set -euo pipefail`, quote
  every variable, `local` in functions, `[[ ]]` over `[ ]`, heredocs over echo
  chains, named constants, capability-probing over parsing error text.
  Auto-invoked on shell edits and multi-step command composition; shellcheck config wins.
argument-hint: '[scan|check <path>]'
allowed-tools:
  - Read
  - Glob
  - Grep
model: haiku
effort: low
model-invocable: true
user-invocable: true
license: MIT
group: workflows
metadata:
  author: whizzzkid
  version: "2026.08.17-202223"
  internal: false
  model:
    openai: gpt-5.6-luna
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Workstyle — Shell (bash/sh)

Enforces safe, idiomatic shell conventions on every shell file and compound
ad-hoc command the agent writes. Part of the `wk-workstyle` family. **Project settings are
authoritative — this skill fills gaps only, never overrides.** When a
linter/formatter config governs a rule below, that config wins; see
`wk-workstyle` Step 0 for the project-style-authority probe.

## When to Use

Auto-invoked for shell-script edits and multi-step command composition. Trigger contexts:

- Writes or edits a `.sh` file, bash/sh script, or bin script with a shell shebang.
- Composes a compound or multi-step bash/sh/zsh command.

Manual: `/wk-workstyle-shell scan` (full working tree) · `/wk-workstyle-shell check <path>` (one file).

## Rules

- **`set -euo pipefail`** at the top of every script.
- **Quote every variable** — `"$var"` not `$var`. Unquoted variables split on whitespace.
- **`local`** for all variables inside functions.
- **`[[ … ]]`** over `[ … ]` in bash.
- **Heredoc** for multi-line strings; avoid concatenated `echo` chains.
- **Named constants** for magic values at the top of the script.
- **`printf '%s'` over `echo` for any captured payload** — `echo` interprets `\r`/`\n`/`\t` and corrupts structured text; prefer a direct pipe.
- **One-line comment above each function** in scripts with ≥3 functions —
  describe what it does and any non-obvious output format (e.g.
  `# Returns the OS name lowercased for package lookup`). Function names lack
  type signatures/docstrings, so this is the only signal about inputs, side
  effects, and output shape. Single-/two-function scripts may skip it.
- **Capture a non-zero exit with `|| status=$?`, never `cmd; status=$?`.** Under
  `set -e`, the `;` separator does not suppress `errexit` — a command that exits
  non-zero terminates the script before the `status=$?` assignment runs. Only `||`
  suppresses `errexit` on its left operand. Initialize `status=0` first, then
  `cmd || status=$?`. Flag any `cmd; status=$?` in a `set -e` script.

  ```bash
  status=0
  http_code=$(helper ...) || status=$?   # captures 2 instead of exiting
  ```

- **Register a cleanup trap the moment you create a temp file or dir** — `trap
  'rm -rf "$tmp"' EXIT INT TERM`, in the same commit, never deferred to a later
  fix. An `EXIT`-only trap leaks the tempfile on Ctrl-C and on CI cancellation;
  cover `INT`/`TERM` too. Pair with the `local`-scope rule below.
- **An EXIT trap cannot see a `local` variable.** A script-scope
  `trap '... "$f" ...' EXIT` runs after functions return, so a `local f` set
  inside a function is out of scope and expands empty — `${f:-}` silently
  swallows the bug and the tempfile leaks on SIGINT/SIGTERM. Declare any var a
  script-level trap cleans up at script scope (init to `""` before the first
  function call), or register tempfiles into a global array the trap iterates.
  Flag any trap referencing a variable that is `local` where it's assigned.
- **Never guard with `${VAR:?msg}` when an `EXIT` trap is registered.** On bash
  3.2 (macOS default), an `EXIT` trap firing on a `:?` expansion failure resets
  `$?` to `0` before the trap body runs → the script exits `0` and the guard
  silently passes. Works on bash 4/5 (Linux CI), fails silently on macOS. Use an
  explicit check instead:

  ```bash
  if [[ -z "${VAR:-}" ]]; then echo "VAR is required" >&2; exit 1; fi
  ```

- **Presence-check with a test builtin, never a value expansion.** `${VAR:-x}` /
  `${VAR-x}` substitutes the default only when the var is *unset* — on the set path it
  emits the value. `${VAR:+yes}${VAR:-NO}` reads like a ternary but is two independent
  expansions, so the common (set) path writes a live secret verbatim to the transcript.
  Treat any `${SECRET:-` / `${SECRET-` on a line reaching stdout/stderr as a disclosure
  requiring rotation. Never put a secret on an argv `ps` can read.

  ```bash
  [ -n "$VAR" ] && echo set || echo unset                      # presence
  printf '%s:%s\n' "${#VAR}" "$(printf %s "$VAR" | shasum | cut -c1-8)"   # fingerprint
  ```

- **Zsh/bash portability:** every command must work under both zsh and bash. Five
  critical traps (word-splitting, indirect expansion, PIPESTATUS, glob qualifiers,
  reserved variables) plus bash 3.2 targeting for macOS hooks.
  Details: [`references/zsh-bash-portability.md`](references/zsh-bash-portability.md).
- **sed/awk/grep/printf trap catalog:** silent-failure traps in common shell tools —
  BSD operand order, PCRE in ERE, awk exit overwrite, sed portability, grep flag
  conflicts, pipeline verdict loss, fallback traps, positive controls.
  Full catalog: [`references/shell-traps.md`](references/shell-traps.md).

## Apply or Report

- **Auto-fixable** (mechanical) → apply silently, note in the commit message.
- **Requires judgment** → surface as a suggestion before committing: what the
  finding is, where, and a concrete fix sketch.
- **Conflicts with project config** → suppress; never fight the linter.
