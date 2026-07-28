---
name: wk-workstyle-structure
description: >-
  Code layout, functions, conditionals, control flow — imports-at-top, guard
  clauses, max nesting depth 3, single-responsibility, no nested ternaries, no
  magic numbers/strings, no boolean-trap params, no commented-out code, and a
  duplication threshold that triggers wk-refactor. Auto-invoked on any function
  body / branching / layout edit; project linter wins.
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
  version: "2026.07.28-171126"
  internal: false
  model:
    openai: gpt-5.6-luna
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Workstyle — Layout & Structure

Enforces code layout and structural quality for every function body, branch, and file the agent writes. Part of the `wk-workstyle` family. **Project settings are authoritative — this skill fills gaps only, never overrides.** When a linter/formatter config governs a rule below, that config wins; see `wk-workstyle` Step 0 for the project-style-authority probe.

## When to Use

Auto-invoked whenever the agent writes or edits a function body, branching logic, or file layout. Trigger contexts:

- Writes or edits a function body, branching logic, control flow, import block, or overall file layout.
- Adds or restructures conditionals, loops, or guard clauses in any language.
- Pastes or rewrites a block that resembles existing code (duplication probe).
- Introduces literals, flags, or boolean parameters into a function signature or body.

Manual: `/wk-workstyle-structure scan` (full working tree) · `/wk-workstyle-structure check <path>` (one file).

## Rules

### Layout

- **Column width 120.** Wrap lines that exceed 120 characters.
  If `.editorconfig` or a linter sets a different value, use that.
- **Spaces, not tabs.** Two-space indent for general languages;
  four spaces for Python (PEP 8). If the project uses tabs (Go,
  Makefile), follow the project.
- **Imports / requires / uses at the top.** Group and sort:
  standard library first, then third-party, then local. A blank
  line between each group. Never scatter imports mid-file.

### Structure

- **No nested ternaries.** One ternary level maximum. Nested
  ternaries → `if/else` or early-return.
- **Guard clauses first.** Return / throw / raise early for
  invalid preconditions rather than wrapping the whole body in an
  `if`. Max nesting depth: 3 levels. Beyond that, extract a function.
- **Single responsibility.** Each function does one thing. Target
  ≤ 30 lines per function (tooling can't enforce this; apply judgment).
- **No magic numbers or magic strings.** Every literal that has
  semantic meaning gets a named constant. `MAX_RETRY_ATTEMPTS = 3`
  not bare `3`. Exception: `0`, `1`, `-1`, `""`, `true`, `false`
  in obvious arithmetic context.
- **No boolean trap parameters.** `createUser(true)` says nothing.
  Use an options object, named keyword args, or an enum:
  `createUser({ notify: true })`.
- **No commented-out code.** Delete it. Git is the history. If it
  must stay for reference, add a comment explaining why it's
  preserved — not just the dead code itself.
- **Avoid duplication.** Before pasting or rewriting a block that
  resembles existing code, grep the codebase for the operation and
  reuse or extract. Three near-duplicates in the diff (or across the
  repo) is the threshold for extracting a helper — once duplication
  ships, every consumer accretes tests against its copy and
  consolidation cost climbs.
  - Two duplicates can stay; copy-paste the third time means lift.
  - Pure-coincidence similarity (same shape, unrelated semantics)
    is not duplication — do not force an abstraction across it.
- **Invoke `wk-refactor` when duplication is frequent.** If the
  current change touches ≥ 3 near-identical sites, or the codebase
  already carries ≥ 5 copies of a pattern the change extends,
  invoke `wk-refactor` to lift-and-migrate **before** extending the
  pattern further. Match the lift → migrate → extend ordering from
  `wk-workflow`'s prefactor probe; new behavior rides on top of the
  helper, not alongside another copy.

## Apply or Report

- **Auto-fixable** (mechanical) → apply silently, note in the commit message.
- **Requires judgment** → surface as a suggestion before committing: what the
  finding is, where, and a concrete fix sketch.
- **Conflicts with project config** → suppress; never fight the linter.

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn workstyle-structure`).
