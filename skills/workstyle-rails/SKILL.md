---
name: wk-workstyle-rails
description: >-
  Use when a Rails/Ruby project command (`bundle exec`, `bin/*`, `rake`,
  `rails`) fails to start with a missing gem or uninitialized environment.
  Enforces the canonical bootstrap (`bin/setup`) before any manual gem install
  or env repair — fix the root cause, don't pivot. Project bootstrap scripts
  are authoritative.
argument-hint: '[check]'
allowed-tools:
  - Read
  - Glob
  - Bash
model: haiku
effort: low
model-invocable: true
user-invocable: true
license: MIT
group: workflows
metadata:
  author: whizzzkid
  version: '2026.07.08-175435'
  internal: false
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Workstyle — Rails

Ensures the agent initializes a Rails project through its canonical bootstrap
script before attempting manual environment repair. Part of the
[`wk-workstyle`](../workstyle/README.md) family. **Project bootstrap scripts
are authoritative — run them, do not reinvent them.**

## When to Use

Auto-invoked whenever a Rails/Ruby project command fails with a missing-gem or
uninitialized-environment error. Trigger contexts:

- A `bundle exec …`, `bin/<script>`, `rake`, or `rails` command fails with
  `GemNotFound`, `Could not find … in locally installed gems`, `cannot load
  such file`, or a similar bundler/environment error.
- About to run `gem install` or `bundle install` manually to fix such a failure.
- Setting up or re-initializing a checked-out Rails repo.

Manual: `/wk-workstyle-rails check` — report the repo's bootstrap entry point.

## Core Rule: bootstrap before manual repair

**When a gem or environment command fails, run the project bootstrap before any
manual `gem install` / `bundle install` / config repair.**

Many Rails repos wrap environment initialization in `bin/setup` — often
delegating to a dev-environment tool (`gdev setup`, `mise exec`, Docker). Until
that script runs, `bundle exec` and `bin/*` commands fail. A failed
infrastructure command is a signal the environment is uninitialized, **not** a
reason to abandon the task and pivot to unrelated code changes.

## Step 1: Locate the bootstrap entry point

Check, in order, for the canonical initializer:

```bash
for f in bin/setup bin/bootstrap script/setup Makefile; do
  test -e "$f" && echo "FOUND: $f"
done
```

- `bin/setup` is the Rails convention and the default target.
- A `Makefile` may expose `make setup` / `make bootstrap` — read it to confirm.
- No bootstrap script found → fall through to Step 3.

## Step 2: Run the bootstrap, then retry

- If authorized to run commands, run the bootstrap and re-run the original
  failing command:

  ```bash
  bin/setup && <original failing command>
  ```

- If not authorized, stop and instruct the user to run it themselves (suggest
  the `! <command>` session prefix), then retry.
- Bootstrap scripts can be slow (gem builds, asset compiles, container starts) —
  allow a generous timeout; do not assume a hang.

## Step 3: Only then, manual repair

- Run manual `bundle install` / `gem install` **only** after the bootstrap
  script is absent or has itself failed.
- A bootstrap failure is the real bug — surface its output; never silently
  pivot away from the blocked task to unrelated edits.

## Common Mistakes

- **Pivoting away on a gem error.** A `GemNotFound` from `bundle exec` means the
  environment is uninitialized, not that the command is wrong. Bootstrap first.
- **Reinventing bootstrap by hand.** Manual `bundle install` skips the dev-tool
  delegation (`gdev`, `mise`, Docker) that `bin/setup` performs — leaving the
  environment half-initialized.
- **Treating a slow bootstrap as a hang.** Allow time for gem builds and
  container starts before aborting.

## Quick Reference

| Trigger | Behavior |
|---------|----------|
| `bundle exec`/`bin/*`/`rails` fails with gem/env error | Locate bootstrap → run it → retry |
| `/wk-workstyle-rails check` | Report the repo's bootstrap entry point |
| No bootstrap script present | Fall through to manual repair |

## Requirements

- Read access to the repo root (`bin/`, `script/`, `Makefile`)
- Bash access to run the bootstrap script (when authorized)

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn workstyle-rails`).
