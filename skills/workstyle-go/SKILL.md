---
name: wk-workstyle-go
description: >-
  Use when writing or editing Go (.go) — enforces handling errors immediately
  as values, fmt.Errorf %w wrapping with context, table-driven tests for
  multi-variant functions, minimal exported API, no panic in library code, and
  defer for cleanup right after acquire. Auto-invoked whenever the agent
  touches a .go file. Project golangci-lint/gofmt config wins.
argument-hint: '[scan|check <path>]'
allowed-tools:
  - Read
  - Glob
  - Grep
model: sonnet
effort: low
model-invocable: true
user-invocable: true
license: MIT
group: workflows
metadata:
  author: whizzzkid
  version: '2026.06.01-224411'
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

## Apply or Report

- **Auto-fixable** (mechanical) → apply silently, note in the commit message.
- **Requires judgment** → surface as a suggestion before committing: what the
  finding is, where, and a concrete fix sketch.
- **Conflicts with project config** → suppress; never fight the linter.

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn workstyle-go`).
