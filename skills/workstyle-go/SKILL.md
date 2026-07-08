---
name: wk-workstyle-go
description: >-
  Go (`.go`) idioms — handle errors as values, `fmt.Errorf %w` wrapping,
  table-driven tests, minimal exported API, no panic in libraries, defer
  cleanup right after acquire. Auto-invoked on any `.go` edit;
  golangci-lint/gofmt config wins.
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

# Workstyle — Go

Enforces idiomatic Go authoring conventions on every `.go` file the agent
writes or edits. Part of the `wk-workstyle` family. **Project settings are
authoritative — this skill fills gaps only, never overrides.** When a
linter/formatter config governs a rule below, that config wins; see
`wk-workstyle` Step 0 for the project-style-authority probe.

## When to Use

Auto-invoked whenever the agent writes or edits a `.go` file. Trigger contexts:

- Creating, editing, or refactoring any `.go` source or `_test.go` file.
- Writing functions that return an `error`.
- Adding or modifying exported identifiers in a package.
- Acquiring resources that need cleanup (open files, locks, connections).

Manual: `/wk-workstyle-go scan` (full working tree) · `/wk-workstyle-go check <path>` (one file).

## Rules

- **Errors are values — handle them immediately** after every function call that returns one.
- **`fmt.Errorf("context: %w", err)`** to wrap with context; never discard.
- **Table-driven tests** for any function with multiple input variants.
- **Unexported identifiers** for package-internal state; only export the minimal API.
- **No `panic` in library code** — return an error.
- **`defer` for cleanup** (close, unlock) immediately after acquire.

## Pre-Commit Gate

Run before invoking `wk-commit` on any change that touched `.go` files:

```bash
gofmt -l .
```

- **The gate is per-commit, not per-session.** Re-run it immediately before
  **every** commit that touched a `.go` file — a clean check earlier in the
  session does not carry forward past the next edit.
- Re-run regardless of edit type: adding, widening, OR **removing** a struct
  tag all shift gofmt's alignment columns (a dropped tag leaves trailing
  inline comments aligned to a now-gone column; gofmt collapses them).

- Treat non-empty output as a **blocking finding, not a suggestion** —
  `gofmt` reformats map literals to align values on the longest key, so a
  hand-written `map[...]...` fails CI's `gofmt -l` check even when local
  tests pass.
- Run `gofmt -w` on every listed file, then re-run `gofmt -l .` to confirm
  empty output before committing.
- Editor / pre-commit-hook formatting does not apply inside an agent
  session — run this check explicitly.
- Substitute the project's pinned formatter (e.g., `gofumpt`) when its
  config declares one; otherwise `gofmt` is the floor.
- **After any structural change to a struct field — add, widen, rename,
  OR remove a tag or field — re-run `goimports` on the whole file —
  `gofmt` is not sufficient.** `gofmt` realigns only
  the changed line; `goimports` recomputes the widest type name across the
  struct and realigns every sibling field's tag column. A file edited by
  format-on-save (`gofmt`) is locally clean but globally misaligned, and
  CI's `goimports -l` fails. When the project runs `goimports` in CI
  (standard for repos with internal imports), format with it explicitly:

  ```bash
  goimports -local github.com/$GITHUB_ORG/<repo> -w <file>
  ```

## Apply or Report

- **Auto-fixable** (mechanical) → apply silently, note in the commit message.
- **Requires judgment** → surface as a suggestion before committing: what the
  finding is, where, and a concrete fix sketch.
- **Conflicts with project config** → suppress; never fight the linter.

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn workstyle-go`).
