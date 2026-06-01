---
name: wk-env
description: >-
  Use when diagnosing environment setup issues — checks that all env vars
  declared in a skill's frontmatter are present, sources $HOME/.profile when
  they are not, reports what is still missing, and provides remediation. Also
  invoked automatically by the Skill PreToolUse hook before any skill that
  declares env-vars in its frontmatter.
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
  version: '2026.06.01-215946'
  model:
    openai: gpt-4.1-nano
    google: gemini-2.5-flash-8b
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Env

Diagnose and report environment variable availability before skill execution.

**Invocation modes:**

| Mode | Trigger |
|------|---------|
| Auto | `PreToolUse` hook fires before any `Skill` tool call; checks `env-vars:` declared in the target skill's frontmatter |
| Manual (`/wk-env`) | Full env report for the current session |
| Manual (`/wk-env <skill-name>`) | Report for vars declared by a specific skill |
| Manual (`/wk-env --check VAR1 VAR2`) | Check a specific list of vars |

---

## Step 1: Identify vars to check

- If invoked with a skill name, read `$WK_SKILLS_HOME/skills/{name}/SKILL.md`
  and extract the `env-vars:` frontmatter list:

  ```bash
  awk '/^---/{n++} n==1 && /^env-vars:/{f=1;next} f && /^  -/{print $2;next} f && !/^  -/{exit}' \
    "$WK_SKILLS_HOME/skills/{name}/SKILL.md"
  ```

- If invoked with `--check VAR1 VAR2`, use those vars directly.
- If invoked with `--all`, collect every unique var from every
  `skills/*/SKILL.md` frontmatter `env-vars:` list.
- If invoked with no args, report the key session vars (see Step 2).

---

## Step 2: Check current process env

For each var, check if it is set in the current process. Build a status
table: `set` (non-empty), `empty` (set to `""`), or `missing` (unset).

```bash
source "$HOME/.profile" 2>/dev/null || true

for var in {VARS}; do
  val=$(printenv "$var" 2>/dev/null || echo "")
  if [ -z "${!var+x}" ] 2>/dev/null; then
    echo "missing  $var"
  elif [ -z "$val" ]; then
    echo "empty    $var"
  else
    echo "set      $var  = ${val:0:60}"
  fi
done
```

When invoked with no args, check this default set:

```bash
WK_SKILLS_HOME GITHUB_ORG EMPLOYER GIT_CONFIG_PARAMETERS
```

---

## Step 3: Source `$HOME/.profile` and re-check missing vars

For each `missing` or `empty` var, source `$HOME/.profile` in a
diagnostic subprocess and re-run the check to show what becomes available:

```bash
bash -c "source $HOME/.profile 2>/dev/null; printenv {VAR}" 2>/dev/null \
  || echo "<still missing after sourcing $HOME/.profile>"
```

Report the result as one of:
- **Resolved after sourcing** — the var is in `$HOME/.profile` but the
  Claude Code process was not launched from a shell that sources it.
- **Still missing** — the var is not defined anywhere in `$HOME/.profile`;
  the user needs to add it.

---

## Step 4: Report and remediate

Print a structured report:

```
wk-env report
─────────────────────────────────────────────────────────
SKILL: {name} (or "session default" if no skill given)
─────────────────────────────────────────────────────────
✅  WK_SKILLS_HOME = /path/to/skills
✅  GITHUB_ORG     = org-name
⚠️  MY_VAR         → resolved after sourcing ~/.profile
                      (restart Claude Code from a shell that sources ~/.profile)
❌  OTHER_VAR      → still missing after sourcing ~/.profile
                      (add to ~/.profile: export OTHER_VAR=<value>)
─────────────────────────────────────────────────────────
```

For any **resolved-after-sourcing** var: the fix is always the same —
restart Claude Code from a login shell (`bash -l` or a new terminal
session) so `$HOME/.profile` is sourced on startup. Do not suggest
adding ad-hoc exports to session config or writing to `.env` files.

For any **still-missing** var: provide the exact line to add to
`$HOME/.profile`:

```
export {VAR}=<value>
```

---

## Step 5: Exit code

- Exit 0 when all declared vars are `set`.
- Exit 1 (soft warning) when any var is resolved-after-sourcing.
- Exit 2 (hard warning) when any var is still-missing.

The `PreToolUse` hook uses the exit code to decide message severity —
it never blocks skill execution, only warns.

---

## Hard Rules

1. **Never write to global config or shell RC to "fix" a missing var.**
   The only correct remediation is: (a) add the export to `$HOME/.profile`
   if it is missing, or (b) restart Claude Code from a shell that sources
   `$HOME/.profile` if the var is already there but not inherited.
2. **Source `$HOME/.profile` read-only in a subprocess.** Never `source`
   it in the current process — the skill runs in a non-interactive context
   where the sourced state would not persist anyway.
3. **Report, don't guess.** Show the actual value when set; show the exact
   unresolved state when missing. Never fabricate a default.

---

## Quick Reference

| Invocation | Behavior |
|-----------|---------|
| `/wk-env` | Session default vars report |
| `/wk-env wk-workflow` | Check vars declared by wk-workflow |
| `/wk-env --check WK_SKILLS_HOME GITHUB_ORG` | Check specific vars |
| `/wk-env --all` | Check all declared vars across all skills |
| Auto (PreToolUse hook) | Checks `env-vars:` of the skill being invoked |

## Requirements

- `$WK_SKILLS_HOME` set to the skills repo root (else runs in degraded
  mode — checks only the default session vars)
- `$HOME/.profile` readable

---

## Common Mistakes

- Treating a signing failure (or any env-dependent failure) as a config
  gap to fill rather than an env inheritance failure to diagnose. The
  correct sequence is always: check env → source `$HOME/.profile` in a
  subprocess → report → restart if resolved-after-sourcing.
- Writing `git config --global user.signingkey` or equivalent to "fix"
  a missing env-delivered config value — this shadows the user's
  env-based config and persists as destructive global state.

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn env`).
