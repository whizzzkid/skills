---
name: wk-env
description: >-
  Use when diagnosing environment setup issues — checks that all env vars
  declared in a skill's frontmatter are present, sources $HOME/.profile when
  they are not, reports what is still missing, and provides remediation. Also
  diagnoses a set-but-stale value (rotated secret) and stops the retry loop it
  causes, and auto-mode denials caused by a hook rewriting Bash input. Also
  invoked automatically by the Skill PreToolUse hook before any
  skill that declares env-vars in its frontmatter.
argument-hint: '[skill-name | --check <VAR> ... | --all]'
allowed-tools:
  - Bash
  - Read
model: haiku
effort: low
model-invocable: true
user-invocable: true
license: MIT
group: workflows
env-vars: []
metadata:
  author: whizzzkid
  version: "2026.10.09-212439"
  model:
    openai: gpt-5.6-luna
    google: gemini-2.5-flash-8b
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Env

Diagnose and report environment variable availability before skill execution. Modes: **auto** — `PreToolUse` hook fires
before any `Skill` tool call and checks the target skill's `env-vars:`; **manual** — `/wk-env` (full session report),
`/wk-env <skill-name>` (that skill's vars), `/wk-env --check VAR1 VAR2` (listed vars).

## Step 1: Identify vars to check

- Skill name given → **resolve its dir by listing, never by transforming the name** (most dirs drop the leading `wk-`,
  some keep it; a blind strip reports a false "declares nothing"). Take the first candidate that exists, verbatim before
  stripped:

  ```bash
  for cand in "{name}" "${name#wk-}"; do
    f="$WK_SKILLS_HOME/skills/$cand/SKILL.md"
    [ -f "$f" ] && { SKILL_FILE="$f"; break; }
  done
  ```

  Then extract the `env-vars:` frontmatter list:

  ```bash
  awk '/^---/{n++} n==1 && /^env-vars:/{f=1;next} f && /^  -/{print $2;next} f && !/^  -/{exit}' \
    "$SKILL_FILE"
  ```

- Unresolvable name is normal input, not an error (plugin and third-party skills ship no dir here): report it as
  unresolved; never conflate it with "declares no env-vars".
- `--check VAR1 VAR2` → use those vars directly. `--all` → collect every unique var from every `skills/*/SKILL.md`
  frontmatter `env-vars:` list. No args → the default set in Step 2.

## Step 2: Check current process env

Classify each var: `set` (non-empty), `empty` (set to `""`), or `missing` (unset).

- `set` proves the var was **inherited**, never that the value is still **valid** — a rotated secret reads `set`. Route
  an auth failure on a `set` var to Step 3.5.
- **Never echo the value of a secret-shaped var** (name matching `TOKEN|KEY|SECRET|PASS|CRED|PAT`) — even a prefix
  discloses it and forces a rotation. Report those as `<len N sha XXXXXXXX>`; print the literal value only for
  non-secret vars (paths, org names).
- Distinguish unset from empty by `printenv` exit status, never `${!var+x}` (bash-only; aborts under zsh with
  `bad substitution`).

```bash
source "$HOME/.profile" 2>/dev/null || true

for var in {VARS}; do
  if ! val=$(printenv "$var"); then
    echo "missing  $var"
  elif [ -z "$val" ]; then
    echo "empty    $var"
  else
    case "$var" in
      *TOKEN*|*KEY*|*SECRET*|*PASS*|*CRED*|*PAT)
        echo "set      $var  = <len ${#val} sha $(printf %s "$val" | shasum | cut -c1-8)>" ;;
      *) echo "set      $var  = ${val:0:60}" ;;
    esac
  fi
done
```

No args → check this default set:

```bash
WK_SKILLS_HOME GITHUB_ORG EMPLOYER GIT_CONFIG_PARAMETERS
```

## Step 3: Source `$HOME/.profile` and re-check missing vars

For each `missing` or `empty` var, source `$HOME/.profile` in a diagnostic subprocess and re-check:

```bash
bash -c "source $HOME/.profile 2>/dev/null; printenv {VAR}" 2>/dev/null \
  || echo "<still missing after sourcing $HOME/.profile>"
```

Still missing → try an interactive login shell (catches interactive-only config: `[[ -o interactive ]]` blocks, plugin
managers); found → export it into the current session:

```bash
zsh -ilc "printenv {VAR}" 2>/dev/null \
  || echo "<still missing after interactive-shell probe>"
```

Report one of: **Resolved after sourcing** (var is in `$HOME/.profile` but Claude Code was not launched from a shell
that sources it); **Resolved after interactive-shell probe** (interactive-only config — export it and note the source);
**Still missing** (defined nowhere in `$HOME/.profile` or interactive config — the user needs to add it).

## Step 3.5: Diagnose a set-but-stale value

Enter only when a var reads `set` **and** the command consuming it fails auth (401 / 403 / expired token): a credential
rotated after this process started leaves a stale copy here.

- Fingerprint before and after **one** source attempt — compare length + hash prefix, never print the secret:

  ```bash
  fp() { printf '%s:%s\n' "${#1}" "$(printf %s "$1" | shasum | cut -c1-8)"; }
  fp "${{VAR}}"                                                            # in-process
  fp "$(bash -c "source \"$HOME/.profile\" 2>/dev/null; printenv {VAR}")"   # after source
  ```

- Fingerprint **changed** → the fresh value is on disk; report resolved-after-sourcing and remediate per Step 4.
- Fingerprint **unchanged** → declare the value **stale-in-process**. Stop and ask the user to restart the session, or
  to run the failing command in their own shell.
- **HARD RULE — never hunt a second shell file, and never retry the command a third time.** Sourcing a static profile
  cannot import a value minted after this process started, so every further attempt fails identically.

## Step 3.6: Diagnose a hook input-rewrite refusal

Enter when a Bash call is denied with `a hook changed this call's input after the model wrote it` (auto-mode
classifier gave no verdict). This is not a missing var: a `PreToolUse` hook on `Bash` emits
`hookSpecificOutput.updatedInput` (e.g. prepends a profile `source`), so the reviewed command differs from the one that
would run. Read-only calls skip the classifier → only writes (push, POST, merge) fail.

- Name the hook — read it, never guess:

  ```bash
  command grep -n 'updatedInput' "$HOME/.claude/settings.json"
  ```

- Retry the identical call **once**, as the denial instructs. Denied again → **HARD RULE — stop; never retry a
  third time** (the hook rewrites every call, so each retry fails identically).
- Hand off: report the hook, the blocked action, and any payload already written to disk; ask the user to re-authorize
  the call or run it themselves.
- Remediate the env, never the call: make the hook observe-only (no `updatedInput`), or remove it and deliver env via
  the login-shell profile the Bash tool already initializes from. Never edit settings yourself (Hard Rule 1).

## Step 4: Report and remediate

Print the structured report: [`references/report-format.md`](references/report-format.md).

- **Resolved-after-sourcing** → always: restart Claude Code from a login shell (`bash -l` or a new terminal session) so
  `$HOME/.profile` is sourced on startup. Never suggest ad-hoc exports to session config or writing to `.env` files.
- **Still-missing** → give the exact line to add to `$HOME/.profile`:

```
export {VAR}=<value>
```

## Step 5: Exit code

Exit 0 when all declared vars are `set`; exit 1 (soft warning) when any var is resolved-after-sourcing; exit 2 (hard
warning) when any var is still-missing or stale-in-process. The `PreToolUse` hook uses the exit code for message
severity — it never blocks skill execution, only warns.

## Hard Rules

1. **Never write to global config or shell RC to "fix" a missing var.** The only correct remediation: (a) add the export
   to `$HOME/.profile` if it is missing, or (b) restart Claude Code from a shell that sources `$HOME/.profile` if the
   var is already there but not inherited. Never write `git config --global user.signingkey` or equivalent for an
   env-delivered value — it shadows env-based config as destructive global state.
2. **Source `$HOME/.profile` read-only in a subprocess.** Never `source` it in the current process — sourced state would
   not persist in this non-interactive context anyway.
3. **Report, don't guess.** Show the value for a non-secret var, a length + hash fingerprint for a secret-shaped one;
   show the exact unresolved state when missing. Never fabricate a default.
4. Treat a signing failure (or any env-dependent failure) as an env inheritance failure to diagnose, never a config gap
   to fill: check env → source `$HOME/.profile` in a subprocess → report → restart if resolved-after-sourcing.

Requires `$HOME/.profile` readable and `$WK_SKILLS_HOME` set to the skills repo root (else degraded mode — checks only
the default session vars).

## Post-Completion

Invoke `wk-learn env`.
