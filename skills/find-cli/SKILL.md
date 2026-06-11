---
name: wk-find-cli
description: >-
  Auto-invoked whenever the agent runs the `find` CLI — enforces PWD-scoped
  searches (no traversal outside the current project), keeps invocations
  minimal and targeted for speed, and reports a learning when a find command
  fails or takes more than 1 second.
model-invocable: true
user-invocable: false
model: haiku
effort: low
license: MIT
group: workflows
metadata:
  author: whizzzkid
  version: '2026.06.11-215001'
---

# find-cli

Rules for every `find` invocation the agent emits. Prevents scope creep
(accidentally searching the whole filesystem), keeps invocations tight for
fast results, and captures slow/failing calls as learnings.

## When to Use

Auto-invoked immediately before any `find` command the agent is about to run.
Fires on:
- `find <path> ...` in a Bash block
- `find "$WK_SKILLS_HOME/..."` or similar when inside a skill

## Step 1: Enforce PWD scope

**HARD RULE — search path must be `.` or a descendant.**

- Resolve the first positional argument to `find`. If it is an absolute path,
  confirm it lives under `$PWD`.
- Paths that escape `$PWD` (e.g., `find /`, `find ~`, `find ..`) are
  **forbidden without an explicit user override.** Replace with `.` or the
  appropriate relative sub-path.

```bash
# Forbidden
find / -name 'foo'
find ~ -name '*.log'
find .. -type f

# Correct — stays in PWD
find . -name 'foo'
find ./src -name '*.ts'
```

When `$WK_SKILLS_HOME` queries are legitimately needed (batch learnings scans,
skill installs), that path is the exception — document the override in a
one-line comment.

## Step 2: Keep invocations minimal and targeted

Apply **at least two** of the following filters on every `find` call:

- `-type f` or `-type d` — never scan both when only one is needed.
- `-name '*.ext'` or `-name 'pattern'` — anchor the search by name.
- `-maxdepth N` — cap traversal depth when the target lives in a known subtree.
- `2>/dev/null` — suppress permission-denied noise on directories the agent
  cannot read.

```bash
# Unfocused — hits every file in the tree
find . -type f

# Focused — name + type + depth cap
find . -name '*.md' -type f -maxdepth 4 2>/dev/null
```

- Prefer `grep -rl` over `find + grep` for content searches — it short-circuits
  on the first match and is significantly faster.
- Prefer `ls` or `Glob` for a flat directory listing instead of `find`.

## Step 3: Time the call and report slow or failing invocations

Wrap the `find` command with `time` (or record wall-clock start/end) when
running in a context where the result set is unknown in advance:

```bash
{ time find . -name '*.learned.md' -type f 2>/dev/null; } 2>&1
```

After the call completes:

- **If exit code ≠ 0** — log a learning: `Skill(wk-learn, args="find-cli")`
  describing the failing command, the error output, and a suggested fix
  (missing `-maxdepth`, wrong start path, permission issue).
- **If elapsed > 1 second** — log a learning: `Skill(wk-learn, args="find-cli")`
  describing the slow invocation, the result count, and the filter change that
  would speed it up next time. Do not re-run without the improved filters.
- **If both pass** — no learning needed; continue.

## Quick Reference

| Check | Rule |
|-------|------|
| Start path | Must be `.` or a subtree of `$PWD` |
| Minimum filters | ≥2 of: `-type`, `-name`, `-maxdepth`, `2>/dev/null` |
| Slow (> 1s) | Log a wk-find-cli learning with the improved filter |
| Failed | Log a wk-find-cli learning with the error and fix |

## Requirements

- `$PWD` set (standard shell guarantee).
- Write access to `$WK_SKILLS_HOME/learnings/skills/find-cli/` for learning capture.

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn find-cli`).
