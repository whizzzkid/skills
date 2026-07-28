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
  version: "2026.07.28-171102"
  model:
    openai: gpt-5.6-luna
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
| `Bash` | A recursive search (`find`, `fd`, `grep -r/-R`, `rg`, `ls -R`) one of whose **path operands** is `/` or normalizes **outside** the repo | **Block** (exit 2) |
| `Bash` | Same search rooted at `.`, a relative path, or an absolute path **inside** the repo | Allow |
| `Bash` | Search whose out-of-repo text sits in its **pattern** operand, or in an unrelated non-search segment | Allow (not a root) |
| `Bash` | Search preceded by `cd`/`pushd` to an out-of-repo path (effective root moved) | **Block** (exit 2) |
| `Edit` / `Write` / `MultiEdit` / `NotebookEdit` | Target file is an absolute path **outside** the repo root | **Warn** (exit 0) — never blocks; writing to `$HOME/.claude` config is legitimate |
| anything | `cwd` is not inside a git repo | Allow (cannot reason about scope) |

The block is deliberately narrow — only recursive **search** commands, and only
when a path argument is genuinely outside the repo. Absolute paths inside the
repo and `cat /etc/hosts`-style non-search reads are never blocked, so the
guard does not train you to disable it.

It is a nudge against accidental scope creep, not a security boundary — an
unexpanded root (see "How it decides", step 2) is not judged at all. **Never
exploit that as a bypass:** rewriting a literal root into `$VAR` to clear a block
is the same self-authorization the opt-out HARD RULE forbids. It matters only for
diagnosis — a passing var-rooted command is not evidence the guard is broken, and
a blocked literal is not evidence the workflow is forbidden.

## Opt out

- Export `SCOPE_GUARD_OFF=1` for the session when an out-of-scope search is
  genuinely required (e.g. locating a system binary).
- **HARD RULE — the opt-out is the user's to grant, never the agent's to
  self-authorize.** Reaching for it after a block is a bypass attempt, and a
  denial of that retry is the correct outcome — treat it as settled, not as an
  obstacle to route around. Reshape the command per the false-block shapes below,
  or ask the user for scope. Never re-attempt the same search with the var added.
- **The opt-out must be an exported/session env var, never a command prefix.**
  `SCOPE_GUARD_OFF=1 grep -r …` in a single Bash call does not disable the guard
  — the hook runs as a separate `PreToolUse` process that inspects the command
  payload before it executes, so a var set on that command line never reaches
  the hook's own environment.

## False blocks — recognize the shape, never bypass

Token inspection is lexical, so a path that *is* in scope can still read as
outside. Reshape the command; do not reach for the opt-out.

- **Path glued to a shell separator** — a `cd <root>;`-style prefix tokenizes as
  `<root>;`, matching neither the repo root nor its prefix, so an in-repo path
  reads as outside. The hook strips trailing `;&|)` before comparing; if a block
  still names a path that looks correct, re-read the reported path for a glued
  separator. Fix: drop the `cd` (CWD already persists between calls).
- **Search rooted in another repo's worktree** — the boundary is the repo of the
  *session's* CWD, so a delegated cross-repo review trips every recursive search
  while the agent stays rooted in the calling repo. A `cd` into the target does
  not move the boundary — its target is charged as the effective root. Fix: root
  the delegated agent's session in the target worktree; searches inside it then
  pass cleanly, because the guard scopes to that session's own repo. Otherwise
  `git grep -n "<term>"` (single pattern, no `-r`) is read-only and passes
  regardless, or ask the user to grant scope for the task.
- **Hand-expanded path where a `$VAR`-rooted one was documented** — a block names
  the token as written, so the same logical path decides differently expanded vs
  `$VAR`-rooted. Fix: leave a documented out-of-repo path in the form its owning
  skill specifies rather than pasting an expanded literal. Never generalize one
  block into "the guard forbids `<workflow>`" — drive the hook with the exact
  command first, or the defect is filed against the wrong axis and the workflow
  degraded to route around a block that was never there.
- **Reshape by subtraction — never swap the verification method.** Drop only the
  blocked element (an out-of-repo temp path, a recursive flag) and keep the
  prescribed matcher, primitive, and comparison. A refused check rewritten with a
  different primitive makes the substitute's tooling difference indistinguishable
  from a real finding. Substitute and prescribed method disagree → the substitute
  is wrong until direct inspection of the underlying data says otherwise.
  - **A preceding `cd` outside the repo still blocks the search that follows** —
    its target is the search's effective root even when the search names only `.`.
    Tell: the reported path is the `cd` target, not the search's own root. Fix:
    drop the `cd` (CWD already persists between calls). An out-of-repo path in an
    unrelated *non-search* segment is not charged against the search, so splitting
    a compound into single-purpose calls is no longer needed for that shape.
  - **Stage out-of-repo scratch through `Write`/`Edit`, not a Bash call** — the
    file-write guard only warns, so a written draft leaves no Bash payload to trip
    while the measuring primitive stays intact.

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
2. Tokenize the command quote-aware (`shlex`), so a quoted string stays ONE
   token — prose inside quotes cannot synthesize a path argument. A genuinely
   quoted root (`find "/etc"`) still unwraps and blocks. Unbalanced quotes fall
   back to a whitespace split (fail closed, never skip the check). Tokens are
   inspected as written and never shell-expanded, so a `$VAR`-rooted or
   command-substituted root is judged as the literal text `$VAR/…` — not an
   absolute path, so no comparison happens.
3. Split the tokens into command segments at shell separators and keep only
   segments that are themselves in-scope searches. Emit only each segment's
   **path operands**, resolved under that tool's own grammar:
   - A grep-family tool's first positional is the *pattern*, not a path — and it
     is absent entirely when `-e`/`-f` supplies the pattern. So a pattern
     carrying path-shaped text (a scrub check grepping *for* absolute-path
     shapes) is never charged as a search root.
   - `find`/`fd` path operands precede the first expression flag, so `-name <x>`
     values are not roots.
   - An unrelated segment's arguments are not search roots at all.
   - **A preceding `cd`/`pushd` target IS charged** against the next in-scope
     search — it moves the *effective* root, so `cd <outside> && grep -r x .`
     blocks even though the search names only `.`.
4. Strip any trailing shell separator (`;&|)`) from each candidate token, then
   normalize it (`os.path.normpath`, no existence required).
5. A path is "outside" when its normalized form does not sit under the repo
   root. Relative paths resolve against `cwd` and are treated as inside.
6. `python3` unavailable → fall back to scanning every whitespace token of the
   whole command (noisier, still closed; never fails open).

## Files

- Hook: `skills/scope-guard/hooks/scope-guard.sh` (installed to
  `$HOME/.agents/skills/wk-scope-guard/hooks/`); registered in
  `$HOME/.claude/settings.json` → `hooks.PreToolUse`.
- Tests: `skills/scope-guard/tests/scope-guard.bats`.

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g.,
`wk-learn scope-guard`).
