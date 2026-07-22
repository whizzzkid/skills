---
name: wk-scope-guard
description: >-
  Use when you want a deterministic guard against scope creep — a PreToolUse
  hook that blocks filesystem-root searches (find /, grep -r /, rg /etc) and
  any recursive search rooted outside the repo, and warns when an Edit/Write
  targets a file outside the project root. Distilled from recurring "what are
  you looking for outside the scope of the project?" corrections. Runs
  automatically once registered; /wk-scope-guard prints the registration and
  self-test.
argument-hint: '[--register | --test]'
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
  version: '2026.07.22-214113'
  model:
    openai: gpt-4.1-nano
    google: gemini-2.5-flash-8b
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Scope Guard

A `PreToolUse` hook that keeps tool calls inside the project scope. Skill text
is advisory and gets rationalized away under pressure; a hook fires every time
and cannot be talked out of. This is the mechanical backstop for the
simplest-viable scope gate in [wk-plan](../plan/README.md).

## What it guards

| Tool | Condition | Action |
|------|-----------|--------|
| `Bash` | A recursive search (`find`, `fd`, `grep -r/-R`, `rg`, `ls -R`) whose search-root path argument is `/` or resolves **outside** the repo | **Block** (exit 2) |
| `Bash` | Same search rooted at `.`, a relative path, or an absolute path **inside** the repo | Allow |
| `Edit` / `Write` / `MultiEdit` / `NotebookEdit` | Target file is an absolute path **outside** the repo root | **Warn** (exit 0) — never blocks; writing to `$HOME/.claude` config is legitimate |
| anything | `cwd` is not inside a git repo | Allow (cannot reason about scope) |

The block is deliberately narrow — only recursive **search** commands, and only
when a path argument is genuinely outside the repo. Absolute paths inside the
repo and `cat /etc/hosts`-style non-search reads are never blocked, so the
guard does not train you to disable it.

## Opt out

- Export `SCOPE_GUARD_OFF=1` for the session when an out-of-scope search is
  genuinely required (e.g. locating a system binary).
- **The opt-out must be an exported/session env var, never a command prefix.**
  `SCOPE_GUARD_OFF=1 grep -r …` in a single Bash call does not disable the guard
  — the hook runs as a separate `PreToolUse` process that inspects the command
  payload before it executes, so a var set on that command line never reaches
  the hook's own environment.

## False block: recursive search + unexpanded glob

- A recursive flag (`-r`/`-R`/`-rl`) plus an unexpanded glob token (`*.go`) can
  be blocked as an unbounded search root even when CWD already resolves inside
  the repo/worktree — the lexical token check flags the glob independently of
  the CWD-based root resolution that clears the non-recursive form.
- Do not reach for the env opt-out here (a command prefix will not work anyway).
  Instead: list the files explicitly and grep those (drop `-r`), or omit `-r`
  when CWD is already the intended search root — the non-recursive form from the
  same CWD passes cleanly.

## Invocation

| Mode | Trigger |
|------|---------|
| Auto | `PreToolUse` hook (matchers `Bash` and `Edit\|Write\|MultiEdit\|NotebookEdit`) fires before every matching tool call |
| `/wk-scope-guard --register` | Print the `$HOME/.claude/settings.json` registration snippet |
| `/wk-scope-guard --test` | Run the hook's bats suite |

## Registration

Hooks load only from `settings.json` (or a plugin manifest), so the script
ships with this skill and a one-line registration points at the installed
path. Add to `$HOME/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash|Edit|Write|MultiEdit|NotebookEdit",
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.agents/skills/wk-scope-guard/hooks/scope-guard.sh"
          }
        ]
      }
    ]
  }
}
```

The hook reads the tool payload from stdin, emits any message to stderr
(visible to Claude), and exits 2 to block or 0 to allow.

## How it decides "outside the repo"

1. Resolve the repo root via `git -C <cwd> rev-parse --show-toplevel`.
2. Normalize each candidate path (`os.path.normpath`, no existence required).
3. A path is "outside" when its normalized form does not sit under the repo
   root. Relative paths resolve against `cwd` and are treated as inside.

## Files

- Hook: `skills/scope-guard/hooks/scope-guard.sh` (installed to
  `$HOME/.agents/skills/wk-scope-guard/hooks/`); registered in
  `$HOME/.claude/settings.json` → `hooks.PreToolUse`.
- Tests: `skills/scope-guard/tests/scope-guard.bats`.

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g.,
`wk-learn scope-guard`).
