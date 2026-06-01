---
name: wk-workstyle-ruby
description: >-
  Use when writing or editing Ruby (.rb files, bin scripts loaded as Ruby) —
  enforces predicate `?` / bang `!` method naming, frozen_string_literal, guard
  returns, enumerable methods over imperative loops, specific exception
  subclasses (no bare RuntimeError, no rescue Exception), and ASCII-only
  comments. Auto-invoked whenever the agent touches Ruby. Project RuboCop config
  wins.
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

# Workstyle — Ruby

Enforces Ruby naming, file, control-flow, enumerable, exception, and comment
idioms on every Ruby file the agent touches. Part of the `wk-workstyle` family.
**Project settings are authoritative — this skill fills gaps only, never
overrides.** When a linter/formatter config governs a rule below, that config
wins; see `wk-workstyle` Step 0 for the project-style-authority probe.

## When to Use

Auto-invoked whenever the agent writes or edits a `.rb` file or a bin script
loaded as Ruby. Trigger contexts:

- Writing or editing a `.rb` file.
- Editing a `bin/` script loaded as Ruby (shebang `#!/usr/bin/env ruby` or
  similar).
- Adding or refactoring Ruby methods, control flow, or exception handling.

Manual: `/wk-workstyle-ruby scan` (full working tree) · `/wk-workstyle-ruby check <path>` (one file).

## Rules

- **Predicate methods end in `?`**; mutating methods end in `!`; follow the Ruby naming contract.
- **`frozen_string_literal: true`** magic comment in every file.
- **Guard `return` / `next` / `break`** at the top of a method rather than `unless … else`.
- **Prefer `map`, `select`, `reduce`** over imperative loops.
- **`raise` specific exception subclasses**, not bare `RuntimeError`.
- **No `rescue Exception`** — rescue `StandardError` at most unless explicitly handling signals.
- **ASCII-only in source comments.** Use `-`, `->`, `--`, `...` — not em dash (`—`), en dash (`–`), smart quotes,
  or Unicode ellipsis. RuboCop's `Style/AsciiComments` enforces this in many Ruby shops; the cop default is
  ASCII-only. Applies to `.rb` files and bin scripts loaded as Ruby.

## Apply or Report

- **Auto-fixable** (mechanical) → apply silently, note in the commit message.
- **Requires judgment** → surface as a suggestion before committing: what the
  finding is, where, and a concrete fix sketch.
- **Conflicts with project config** → suppress; never fight the linter.

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn workstyle-ruby`).
