---
name: wk-workstyle-ruby
description: >-
  Ruby (`.rb`, bin scripts loaded as Ruby) — predicate `?` / bang `!` naming,
  frozen_string_literal, guard returns, enumerable methods over imperative
  loops, specific exception subclasses (no bare RuntimeError, no `rescue
  Exception`), ASCII-only comments. Auto-invoked on any Ruby edit; RuboCop
  config wins.
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
  version: '2026.07.09-223249'
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
- **Parenthesize endless/beginless ranges in `case/when`**: `when (50..)`, `when (..29)`. A bare `when 50..` parses the range as extending into the next expression → empty `when` branch → RuboCop `Lint/RequireRangeParentheses` + `Lint/EmptyWhen`.
- **`raise` specific exception subclasses**, not bare `RuntimeError`.
- **No `rescue Exception`** — rescue `StandardError` at most unless explicitly handling signals.
- **ASCII-only in source comments.** Use `-`, `->`, `--`, `...` — not em dash (`—`), en dash (`–`), smart quotes,
  or Unicode ellipsis. RuboCop's `Style/AsciiComments` enforces this in many Ruby shops; the cop default is
  ASCII-only. Applies to `.rb` files and bin scripts loaded as Ruby.
- **Literal single space in a regex → `\x20`**, never a bare space (invisible) or `[ ]` (RuboCop `Style/RedundantRegexpCharacterClass` rejects the class).

## Sorbet strict-mode friction (typed Rails apps)

- **Exercise a shared base-controller `before_action` via a concrete named subclass in the spec**, not an anonymous `controller do … end` block — the block form trips `Sorbet/BlockMethodDefinition` against the no-metaprogramming cop.
- **Prefer a plain sig'd class with an inlined filter over `ActiveSupport::Concern`** when the app has no concern precedent and Sorbet `requires_ancestor` + `included do` fails to type-check.

## Verify with RuboCop

- **Run `bundle exec rubocop --no-color <changed-files>` on every changed `.rb` file before staging** — layout and style cops (argument line breaks, non-ASCII comment characters) are not reliably caught by inspection alone; only the linter sees them. Skipping the local run defers the catch to CI and forces a follow-up fix commit.
- Fix every offense before `wk-commit`.
- Skip only when the repo has no RuboCop config or `bundle exec rubocop` is unavailable.

## Apply or Report

- **Auto-fixable** (mechanical) → apply silently, note in the commit message.
- **Requires judgment** → surface as a suggestion before committing: what the
  finding is, where, and a concrete fix sketch.
- **Conflicts with project config** → suppress; never fight the linter.

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn workstyle-ruby`).
