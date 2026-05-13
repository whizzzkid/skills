---
name: wk-mise
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
  - Write
model: sonnet
effort: low
model-invocable: true
user-invocable: true
license: MIT
group: tools
metadata:
  author: whizzzkid
  version: '2026.05.13-003344'
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
tool versions for the current directory before running. See the
`mise exec --` pattern below.

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
see the `mise exec --` pattern in the next section.

## Diagnosing Toolchain Version Mismatch (silent failure)

When a tool **is** on `$PATH` but the system version differs from the
project's mise-pinned version, the failure is not "command not found" —
it is a confusing build/runtime error from the tool itself. Treat any
of these signals as a mise-mismatch:

- Go: `compile: version "goX.Y" does not match go tool version "goA.B"`
  on stdlib packages.
- Node: `The engine "node" is incompatible with this module` or
  syntax errors on features the pinned version supports.
- Python: `SyntaxError` on features the pinned version supports;
  `pip` resolving wheels for a different ABI.
- Ruby: `Your Ruby version is X, but your Gemfile specified Y`.

The fix is the same as the missing-tool case — prefix the command with
`mise exec --` so mise activates the pinned toolchain before invoking
the tool:

```bash
mise exec -- go build ./...
mise exec -- go test ./...
mise exec -- node --version
mise exec -- bundle exec rspec
```

Apply this to **every** invocation of a mise-managed tool in a repo
with a matching `.mise.toml` entry, not just commands that previously
failed — a working bare invocation today silently breaks when the
system version drifts.

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
mise exec node@{version} -- node --version
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
mise use node@{version}          # pins to project .mise.toml
mise use --global node@{version} # pins globally
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
node = "{version}"
ruby = "{version}"
python = "{version}"
go = "{version}"
```

### `.tool-versions` (legacy asdf format)

```
node {version}
ruby {version}
python {version}
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

## Git Hooks and Mise

When a repo uses git hooks (lefthook, husky, pre-commit) that call
mise-managed binaries, hooks fail with "command not found" (exit 127) for
the same reason described in "How Mise Works" above — the shims directory
is not on `$PATH` in non-interactive shells.

**Before `git push` or `git commit` in a mise-managed repo:**

```bash
eval "$(mise activate bash)" && git push
```

This loads mise's tool paths into the current shell before the hook runs.

**How to detect:** If a git hook fails with exit 127 and the missing tool
is in `mise ls`, this is the cause. Activate mise and retry.

## Quick Reference

| Situation | Command |
|-----------|---------|
| Tool not found in Claude/CI context | `mise exec -- <tool> [args]` |
| Check what's installed | `mise ls` |
| Install project tools | `mise install` |
| Pin a tool version | `mise use node@{version}` |
| Find where a tool is | `mise which <tool>` |
| Debug mise setup | `mise doctor` |
| Trust project config | `mise trust` |

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn mise`).
