---
name: wk-workstyle-shell
description: >-
  Use when writing or editing shell scripts (bash/sh, .sh files, bin scripts) — enforces set -euo pipefail, quoting every variable, local in functions, [[ ]] over [ ], heredocs over echo chains, named constants, and capability-probing instead of parsing error-message text. Auto-invoked whenever the agent touches a shell script. Project shellcheck config wins.
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
  version: '2026.06.22-175725'
  internal: false
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Workstyle — Shell (bash/sh)

Enforces safe, idiomatic shell-script conventions on every shell file the agent
writes or edits. Part of the `wk-workstyle` family. **Project settings are
authoritative — this skill fills gaps only, never overrides.** When a
linter/formatter config governs a rule below, that config wins; see
`wk-workstyle` Step 0 for the project-style-authority probe.

## When to Use

Auto-invoked whenever the agent writes or edits a shell script. Trigger contexts:

- writes or edits a `.sh` file, a bash/sh script, or a bin script with a shell shebang.

Manual: `/wk-workstyle-shell scan` (full working tree) · `/wk-workstyle-shell check <path>` (one file).

## Rules

- **`set -euo pipefail`** at the top of every script.
- **Quote every variable** — `"$var"` not `$var`. Unquoted variables split on whitespace.
- **`local`** for all variables inside functions.
- **`[[ … ]]`** over `[ … ]` in bash.
- **Heredoc** for multi-line strings; avoid concatenated `echo` chains.
- **Named constants** for magic values at the top of the script.
- **Capture a non-zero exit with `|| status=$?`, never `cmd; status=$?`.** Under
  `set -e`, the `;` separator does not suppress `errexit` — a command that exits
  non-zero terminates the script before the `status=$?` assignment runs. Only `||`
  suppresses `errexit` on its left operand. Initialize `status=0` first, then
  `cmd || status=$?`. Flag any `cmd; status=$?` in a `set -e` script.

  ```bash
  status=0
  http_code=$(helper ...) || status=$?   # captures 2 instead of exiting
  ```

- **An EXIT trap cannot see a `local` variable.** A script-scope
  `trap '... "$f" ...' EXIT` runs after functions return, so a `local f` set
  inside a function is out of scope and expands empty — `${f:-}` silently
  swallows the bug and the tempfile leaks on SIGINT/SIGTERM. Declare any var a
  script-level trap cleans up at script scope (init to `""` before the first
  function call), or register tempfiles into a global array the trap iterates.
  Flag any trap referencing a variable that is `local` where it's assigned.
- **Target bash 3.2** for any hook or script that may run under the macOS
  system bash (`/bin/bash`). Avoid bash-4+ builtins — `mapfile`/`readarray`,
  associative arrays (`declare -A`), `${var^^}`/`${var,,}` case conversion,
  negative array indices. Replace `mapfile -t arr < <(cmd)` with
  `while IFS= read -r x; do …; done <<< "$(cmd)"`. Verify with
  `/bin/bash script.sh` (3.2) before committing — `mapfile: command not found`
  is the classic 4-only failure. Detect support for a flag or feature by running it against a known-good input and branching on the exit code — never by grepping the stderr wording. Error strings differ between GNU coreutils, BSD/macOS, BusyBox, and library wrappers, so wording-based fallbacks fail closed on the variant they were supposed to handle.

  ```bash
  # WRONG — wording varies by vendor (BusyBox vs GNU vs macOS)
  if tool -flag -- "$arg" 2>&1 | grep -q "invalid option"; then
      fallback
  fi

  # CORRECT — capability probe
  if tool -flag -- /known-good >/dev/null 2>&1; then
      use_tool
  else
      fallback
  fi
  ```

## Apply or Report

- **Auto-fixable** (mechanical) → apply silently, note in the commit message.
- **Requires judgment** → surface as a suggestion before committing: what the
  finding is, where, and a concrete fix sketch.
- **Conflicts with project config** → suppress; never fight the linter.

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn workstyle-shell`).
