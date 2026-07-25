---
name: wk-workstyle-shell
description: >-
  Shell scripts (bash/sh, `.sh`, bin scripts) — `set -euo pipefail`, quote
  every variable, `local` in functions, `[[ ]]` over `[ ]`, heredocs over echo
  chains, named constants, capability-probing over parsing error text.
  Auto-invoked on any shell edit; shellcheck config wins.
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
  version: '2026.07.24-235129'
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

- **Keep any snippet a skill documents for the agent to run portable to zsh, not just
  bash** — the agent's shell is not guaranteed to be bash, and a shell-dependent
  expansion fails as a plausible *domain* error (nothing matched, var missing) rather
  than a syntax error, so it is diagnosed as a real result. Two traps:
  - `for x in $LIST` — unquoted **parameter** expansion does not word-split under zsh,
    so the body runs once over the whole newline-joined blob; every element-wise command
    fails and any no-match sentinel survives untouched. Use
    `while IFS= read -r x; do …; done <<< "$LIST"`. (Unquoted **command substitution**
    `$(cmd)` does split under both, but still breaks on whitespace within an element.)
  - `${!var}` indirect expansion — bash-only; aborts the whole snippet under zsh with
    `bad substitution`. Distinguish unset from empty by exit status instead:
    `if val=$(printenv "$var"); then …` (rc 1 = unset, rc 0 + empty = set-but-empty).
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

- **On macOS/BSD, options are not reordered after the first operand.** `mv src -v`
  treats `-v` as the *destination*, silently renaming `src` to `./-v` — GNU would
  read it as a flag. Put flags before operands, or terminate options with `--`.
- **Run only commands with a known, intended effect** — never a speculative "guard"
  line whose parse you have not verified; on BSD a stray flag lands as an operand
  and mutates the filesystem.
- **Never emit `sed -i` for an in-place edit.** BSD/macOS `sed` requires an explicit
  backup-suffix argument, so the GNU spelling `sed -i 's/a/b/' file` consumes the
  script as the suffix and fails. Use `perl -pi -e 's{a}{b};' file` — identical
  semantics on both platforms, no platform branch, and `{}` delimiters avoid escaping
  slashes in paths. Reserve `sed` for read-only stream transforms.

## Apply or Report

- **Auto-fixable** (mechanical) → apply silently, note in the commit message.
- **Requires judgment** → surface as a suggestion before committing: what the
  finding is, where, and a concrete fix sketch.
- **Conflicts with project config** → suppress; never fight the linter.

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn workstyle-shell`).
