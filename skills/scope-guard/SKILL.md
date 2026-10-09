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
  version: "2026.10.09-184159"
  model:
    openai: gpt-5.6-luna
    google: gemini-2.5-flash-8b
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Scope Guard

A `PreToolUse` hook that keeps tool calls inside the project scope: the mechanical backstop for the simplest-viable
scope gate in [wk-plan](../plan/README.md), firing every time where skill text gets rationalized away.

## What it guards

| Tool | Condition | Action |
|------|-----------|--------|
| `Bash` | A recursive search (`find`, `fd`, `grep -r/-R`, `rg`, `ls -R`) one of whose **path operands** is `/` or normalizes **outside** the repo | **Block** (exit 2) |
| `Bash` | Same search rooted at `.`, a relative path, or an absolute path **inside** the repo | Allow |
| `Bash` | Search whose out-of-repo text sits in its **pattern** operand, or in an unrelated non-search segment | Allow (not a root) |
| `Bash` | Search preceded by `cd`/`pushd` to an out-of-repo path (effective root moved) | **Block** (exit 2) |
| `Edit` / `Write` / `MultiEdit` / `NotebookEdit` | Target file is an absolute path **outside** the repo root | **Warn** (exit 0) — never blocks; writing to `$HOME/.claude` config is legitimate |
| anything | `cwd` is not inside a git repo | Allow (cannot reason about scope) |

- The block is deliberately narrow: only recursive **search** commands with a path argument genuinely outside the repo;
  in-repo absolute paths and `cat /etc/hosts`-style non-search reads never block.
- It is a nudge against accidental scope creep, not a security boundary: an unexpanded root (`$VAR/…`, see [how it
  decides](references/how-it-decides.md), step 2) is not judged at all. **Never exploit that as a bypass:** rewriting a
  literal root into `$VAR` to clear a block is the same self-authorization the opt-out HARD RULE forbids. Use it only
  for diagnosis: a passing var-rooted command is not evidence the guard is broken, and a blocked literal is not evidence
  the workflow is forbidden.

## Opt out

- Export `SCOPE_GUARD_OFF=1` for the session when an out-of-scope search is genuinely required (e.g. locating a system
  binary).
- **HARD RULE — the opt-out is the user's to grant, never the agent's to self-authorize.** Reaching for it after a block
  is a bypass attempt, and a denial of that retry is the correct outcome — treat it as settled, not as an obstacle to
  route around. Reshape the command per the false-block shapes below, or ask the user for scope. Never re-attempt the
  same search with the var added.
- **The opt-out must be an exported/session env var, never a command prefix:** `SCOPE_GUARD_OFF=1 grep -r …` in one Bash
  call does not disable the guard, because the hook is a separate `PreToolUse` process inspecting the payload before it
  executes.

## False blocks — recognize the shape, never bypass

Token inspection is lexical, so an in-scope path can still read as outside. Reshape the command; never reach for the
opt-out.

- **Path glued to a shell separator:** a `cd <root>;` prefix tokenizes as `<root>;`. The hook strips trailing `;&|)`; if
  a block still names a correct-looking path, re-read it for a glued separator. Fix: drop the `cd` (CWD already persists
  between calls).
- **Search rooted in another repo's worktree:** the boundary is the repo of the *session's* CWD, so a delegated
  cross-repo review trips every recursive search; a `cd` into the target does not move the boundary (its target is
  charged as the effective root). Take the first that works: 1) root the delegated agent's session in the target
  worktree (searches then pass, scoped to that session's repo); 2) `git grep -n "<term>"` (single pattern, no `-r`,
  read-only) passes regardless; 3) ask the user to grant scope for the task.
- **Hand-expanded path where a `$VAR`-rooted one was documented:** a block names the token as written, so the same
  logical path decides differently expanded vs `$VAR`-rooted. Fix: keep a documented out-of-repo path in the form its
  owning skill specifies, never a pasted expanded literal. Never generalize one block into "the guard forbids
  `<workflow>`": drive the hook with the exact command first, or the defect is filed against the wrong axis and the
  workflow degraded to route around a block that was never there.
- **Reshape by subtraction — never swap the verification method.** Drop only the blocked element (an out-of-repo temp
  path, a recursive flag) and keep the prescribed matcher, primitive, and comparison; a different primitive makes its
  tooling difference indistinguishable from a real finding. Substitute and prescribed method disagree → the substitute
  is wrong until direct inspection of the underlying data says otherwise.
  - **A preceding `cd` outside the repo still blocks the search that follows,** even when the search names only `.`.
    Tell: the reported path is the `cd` target, not the search's own root. Fix: drop the `cd`. An out-of-repo path in an
    unrelated *non-search* segment is not charged, so splitting a compound into single-purpose calls is not needed for
    that shape.
  - **Stage out-of-repo scratch through `Write`/`Edit`, not a Bash call:** the file-write guard only warns, so a written
    draft leaves no Bash payload to trip while the measuring primitive stays intact.

## Invocation

- Auto: `PreToolUse` hook (matchers `Bash` and `Edit\|Write\|MultiEdit\|NotebookEdit`) fires before every matching tool
  call.
- `/wk-scope-guard --register`: print the `$HOME/.claude/settings.json` registration snippet.
- `/wk-scope-guard --test`: run the hook's bats suite.

## Registration

Hooks load only from `settings.json` (or a plugin manifest); add to `$HOME/.claude/settings.json`:

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

The hook reads the tool payload from stdin, emits any message to stderr (visible to Claude), and exits 2 to block or 0
to allow.

## How it decides "outside the repo"

Resolve the repo root with `git rev-parse --show-toplevel`, tokenize quote-aware without shell expansion, charge only
search path operands (plus a preceding `cd`/`pushd` target), strip trailing `;&|)`, normalize, and compare against the
root; fail closed when `python3` is missing. Full algorithm:
[references/how-it-decides.md](references/how-it-decides.md).

## Files

- Hook: `skills/scope-guard/hooks/scope-guard.sh` (installed to `$HOME/.agents/skills/wk-scope-guard/hooks/`);
  registered in `$HOME/.claude/settings.json` → `hooks.PreToolUse`.
- Tests: `skills/scope-guard/tests/scope-guard.bats`.

## Post-Completion

Invoke `wk-learn scope-guard`.
