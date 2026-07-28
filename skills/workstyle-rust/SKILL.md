---
name: wk-workstyle-rust
description: >-
  Rust (`.rs`) — no `.unwrap()`/`.expect()` in production paths (use `?` or
  match), `&str` over `String` for borrowed params, `derive(Debug)` on public
  types, `clippy::all` clean before commit, `///` docs with an Examples section
  on public items. Auto-invoked on any `.rs` edit; rustfmt/clippy config wins.
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
  version: "2026.07.28-171124"
  internal: false
  model:
    openai: gpt-5.6-luna
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Workstyle — Rust

Rust-specific code-quality gate for `.rs` files. Part of the `wk-workstyle`
family. **Project settings are authoritative — this skill fills gaps only,
never overrides.** When a linter/formatter config governs a rule below, that
config wins; see `wk-workstyle` Step 0 for the project-style-authority probe.

## When to Use

Auto-invoked whenever the agent writes or edits a `.rs` file. Trigger contexts:

- Writing or editing a `.rs` file.

Manual: `/wk-workstyle-rust scan` (full working tree) · `/wk-workstyle-rust check <path>` (one file).

## Rules

- **No `.unwrap()` or `.expect()` in production code paths** — propagate with `?` or match.
- **Prefer `&str` over `String`** for parameters that don't need ownership.
- **Derive `Debug`** on all public types.
- **`clippy::all`** passes before commit.
- **Document public items** with `///` doc comments; include an `# Examples` section for non-trivial items.

## Apply or Report

- **Auto-fixable** (mechanical) → apply silently, note in the commit message.
- **Requires judgment** → surface as a suggestion before committing: what the
  finding is, where, and a concrete fix sketch.
- **Conflicts with project config** → suppress; never fight the linter.

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn workstyle-rust`).
