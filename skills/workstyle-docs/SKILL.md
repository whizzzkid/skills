---
name: wk-workstyle-docs
description: >-
  Inline and prose comments (NOT structured docstrings — that's
  wk-workstyle-docstrings). Requires WHY-not-WHAT decision comments and
  mandatory removal of stale comments when editing adjacent code. Auto-invoked
  on any inline-comment edit; project linter wins.
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
  version: '2026.07.08-175643'
  internal: false
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Workstyle — Code Documentation

Governs documentation comments and inline comments so public APIs are
documented and every comment explains WHY, not WHAT. Part of the
`wk-workstyle` family. **Project settings are authoritative — this skill fills
gaps only, never overrides.** When a linter/formatter config governs a rule
below, that config wins; see `wk-workstyle` Step 0 for the
project-style-authority probe.

## When to Use

Auto-invoked whenever the agent adds or edits a doc comment, docstring, inline
comment, or any new public function/method/class. Trigger contexts:

- Adding or editing a JSDoc block, Python docstring, Rustdoc `///`, Go doc
  comment, or Ruby YARD comment.
- Writing or editing an inline `//`, `#`, or block comment.
- Declaring a new public function, method, or class in any language.
- Editing code adjacent to an existing comment (stale-comment check applies).

Manual: `/wk-workstyle-docs scan` (full working tree) · `/wk-workstyle-docs check <path>` (one file).

## Rules

- **JSDoc / docstring for every new public function, method, or
  class.** Document: what it does (one sentence), parameters with
  types, return type and shape, exceptions thrown. For non-JS
  languages use the language-native equivalent (Python docstring,
  Rustdoc `///`, Go doc comment, Ruby YARD, etc.).
  - Skip for trivial private helpers where the name is self-
    explanatory and the signature is ≤ 2 obvious params.
- **Comment critical decisions.** Leave a one-line comment when:
  - A non-obvious algorithm or formula is used.
  - A counterintuitive value or order is required.
  - A workaround for an external bug or constraint exists.
  - A performance trade-off was consciously made.
  Do NOT comment what the code does (that's what the code is for).
  Comment WHY it does it that way.
- **No stale comments.** When editing code, update or delete any
  comment that no longer accurately describes the adjacent code.
  Stale comments are worse than no comment.

## Apply or Report

- **Auto-fixable** (mechanical) → apply silently, note in the commit message.
- **Requires judgment** → surface as a suggestion before committing: what the
  finding is, where, and a concrete fix sketch.
- **Conflicts with project config** → suppress; never fight the linter.

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn workstyle-docs`).
