---
name: wk:mise
description: >-
  Use when working with mise (formerly rtx) — installing tools, managing
  .mise.toml or .tool-versions configs, running commands in mise context,
  or diagnosing "command not found" errors for tools managed by mise (node,
  ruby, python, go, rust, bun, terraform, etc.). Auto-invoked when a tool
  is unavailable but likely installed via mise.
allowed-tools:
  - "Bash(mise --version:*)"
  - "Bash(mise ls:*)"
  - "Bash(mise ls-remote:*)"
  - "Bash(mise current:*)"
  - "Bash(mise which:*)"
  - "Bash(mise where:*)"
  - "Bash(mise env:*)"
  - "Bash(mise exec:*)"
  - "Bash(mise install:*)"
  - "Bash(mise use:*)"
  - "Bash(mise plugins:*)"
  - "Bash(mise doctor:*)"
  - "Bash(mise trust:*)"
  - Read
  - Glob
  - AskUserQuestion
  # Learning capture (post-completion hook)
  - Write
  - "Bash(mkdir -p:*)"
model: sonnet
effort: low
model-invocable: true
user-invocable: true
license: MIT
metadata:
  author: whizzzkid
  version: '1.0.0'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-1.5
---

# Mise

Workflows for mise — the polyglot runtime version manager. Covers tool
installation, version configuration, and running commands when mise-managed
tools are not on the PATH.

## When to Activate

Auto-invoke this skill when:

- A command fails with `command not found` for a tool commonly managed by
  mise (node, npm, npx, ruby, python, go, rust, bun, deno, terraform, etc.)
- A project has `.mise.toml` or `.tool-versions` in its root
- The user asks to install, pin, or switch a runtime version
- A script fails because a tool version doesn't match what the project expects
- `mise doctor` output or trust errors appear in the shell

## How Mise Works

Mise manages per-project tool versions via `.mise.toml` (preferred) or
`.tool-versions`. It shims tools into `~/.local/share/mise/shims/` and
activates the right version when you enter a project directory.

**The problem:** When running commands from within Claude Code (or any
non-interactive shell), the mise shims directory may not be on `$PATH`,
so tools appear missing even though they are installed.

**The fix:** Prefix any command with `mise exec --` to load the correct
tool versions for the current directory before running.

```bash
# Instead of:
node --version        # → "command not found"

# Use:
mise exec -- node --version   # → loads mise context, runs node
```

## Diagnosing "Command Not Found"

When a tool is not found, check whether mise manages it before assuming
it's uninstalled:

```bash
# 1. Is mise available?
mise --version

# 2. What tools does mise know about in this directory?
mise ls

# 3. Where is the tool installed?
mise which node     # or ruby, python, go, bun, etc.

# 4. What version is active here?
mise current
```

If `mise which <tool>` returns a path but the tool isn't on `$PATH`,
use `mise exec --` to run it.

## Running Commands with Mise Context

**Single command:**

```bash
mise exec -- <command> [args...]
```

**Examples:**

```bash
mise exec -- node --version
mise exec -- npm install
mise exec -- bundle exec rspec
mise exec -- python -m pytest
mise exec -- go build ./...
mise exec -- bun run dev
```

**Explicit tool version for a single command:**

```bash
mise exec node@20.11.0 -- node --version
```

**Running a script that calls multiple tools:**

Prefer wrapping the full script invocation:

```bash
mise exec -- bash -c 'npm ci && npm run build && npm test'
```

## Checking and Installing Tools

### See what's installed vs. required

```bash
mise ls
```

Shows all configured tools, their required version (from `.mise.toml`),
and whether they are installed.

### Install missing tools for the current project

```bash
mise install
```

Installs all tools listed in `.mise.toml` or `.tool-versions` in the
current directory. Run this when `mise ls` shows tools as not installed.

### Install a specific tool version

```bash
mise use node@22.3.0       # pins to project .mise.toml
mise use --global node@22.3.0  # pins globally
```

Always pin to an exact version — never use `latest` or `lts`.

### List available versions

```bash
mise ls-remote node        # all available node versions
mise ls-remote node | grep "^22\."  # filter to major
```

## Configuration Files

### `.mise.toml` (preferred)

```toml
[tools]
node = "22.3.0"
ruby = "3.3.1"
python = "3.12.4"
go = "1.22.5"
```

### `.tool-versions` (legacy asdf format)

```
node 22.3.0
ruby 3.3.1
python 3.12.4
```

When both exist in the same directory, `.mise.toml` takes precedence.

## Trust Issues

If mise refuses to activate tools with a trust warning:

```bash
mise trust            # trust .mise.toml in current directory
mise trust --all      # trust all configs (use with caution)
```

## Diagnosing Mise Setup

```bash
mise doctor
```

Reports: PATH configuration, shims status, plugin health, and any
configuration conflicts. Run this first when mise behaves unexpectedly.

## Quick Reference

| Situation | Command |
|-----------|---------|
| Tool not found in Claude/CI context | `mise exec -- <tool> [args]` |
| Check what's installed | `mise ls` |
| Install project tools | `mise install` |
| Pin a tool version | `mise use node@22.3.0` |
| Find where a tool is | `mise which <tool>` |
| Debug mise setup | `mise doctor` |
| Trust project config | `mise trust` |

---

## Post-Completion: Learning Capture

**After this skill finishes its primary work**, capture what happened
before returning control.

### Check environment

```bash
test -n "$WK_SKILLS_HOME" && echo "OK: $WK_SKILLS_HOME" || echo "MISSING"
```

If `$WK_SKILLS_HOME` is not set, ask the user:

> "`$WK_SKILLS_HOME` is not set. Please add
> `export WK_SKILLS_HOME=/path/to/skills` to your shell profile and
> restart your terminal."

**Stop here if the variable is missing.** Do not guess or use a fallback.

### Reflect

Review what happened during this skill's execution:

1. **What went wrong?** — Errors, wrong assumptions, user corrections,
   API failures, unexpected behavior
2. **What was missing?** — Steps the skill should have included, edge
   cases not covered, tools not available
3. **What worked well?** — Approaches that succeeded, patterns worth
   reinforcing
4. **What surprised you?** — Non-obvious discoveries that future runs
   should know about

If ALL lenses are empty (routine execution, nothing notable), **skip
writing** — not every run produces a learning.

### Write the learning

```bash
mkdir -p "$WK_SKILLS_HOME/learnings/skills/mise"
```

Write to
`$WK_SKILLS_HOME/learnings/skills/mise/<YYYY-MM-DD>_<learning-slug>.md`:

```markdown
---
skill: wk:mise
date: <YYYY-MM-DD>
type: <correction | gap | pattern | surprise>
severity: <low | medium | high>
---

<One-line summary>

**What happened:** <What the skill did or failed to do>

**Root cause:** <Why — missing instruction, wrong assumption, edge case>

**Suggested fix:** <What should change in the skill to prevent this>
```

Use a 2-4 word kebab-case slug (e.g., `missing-null-check`,
`wrong-api-endpoint`, `good-parallel-pattern`).

### Signal for distillation

After writing, note:

> "📝 Learning captured: `mise/<date>_<slug>.md` — distill with
> `wk:sharpen` when ready."

Learnings accumulate in `$WK_SKILLS_HOME/learnings/skills/` and are
batch-distilled into skill improvements via `wk:sharpen`.
