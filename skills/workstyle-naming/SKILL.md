---
name: wk-workstyle-naming
description: >-
  Use when naming or renaming any identifier in code the agent writes or edits —
  variables, functions, methods, classes, constants, booleans. Enforces
  descriptive names, ALL_CAPS constants, boolean predicate naming (isLoading,
  hasPermission), and a semantic-accuracy gate — a name must truthfully describe
  what its value means, not just pass casing rules. Auto-invoked whenever the
  agent introduces or changes an identifier. Project linter config wins.
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
  version: '2026.06.11-193514'
  internal: false
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Workstyle — Naming

Enforces descriptive, semantically accurate identifier names for every variable,
function, class, and constant the agent writes. Part of the `wk-workstyle`
family. **Project settings are authoritative — this skill fills gaps only, never
overrides.** When a linter/formatter config governs a rule below, that config
wins; see `wk-workstyle` Step 0 for the project-style-authority probe.

## When to Use

Auto-invoked whenever the agent introduces or renames any identifier. Trigger
contexts:

- Declaring or renaming a variable, parameter, or field.
- Naming or renaming a function or method.
- Naming or renaming a class, struct, interface, type, or enum.
- Introducing or renaming a constant.
- Naming a boolean variable, flag, or predicate function.
- Choosing or changing a file/module name.

Manual: `/wk-workstyle-naming scan` (full working tree) · `/wk-workstyle-naming check <path>` (one file).

## Rules

- **Descriptive variable names.** Never single-letter except loop
  indices (`i`, `j`, `k`) in trivial loops. Avoid abbreviations
  (`userCount` not `usrCnt`, `initialize` not `init` in method
  names).
  - Full names apply in **all scopes** — test code, one-off locals, inline
    temporaries — not just production or public APIs. There is no
    test-local or temporary exemption.
  - Initialisms (`ci`, `cb`, `ts`) and ad-hoc aliases are always wrong
    unless they are the established project convention
    (`caseInsensitiveCases`, not `ciCases`).
- **Constants in ALL_CAPS** (unless project convention differs, e.g.
  Go exported identifiers use PascalCase, Rust uses SCREAMING_SNAKE).
  Never hardcode a string or number that recurs or carries semantic
  meaning — assign it a named constant.
- **Boolean variables and functions read as assertions.**
  `isLoading`, `hasPermission`, `canRetry` — not `loading`, `perm`,
  `retry`.
- **Names must be semantically accurate, not just well-formatted.**
  Verify each introduced identifier truthfully describes what its value
  *means*, not merely what it *contains* — a name can pass every casing,
  length, and abbreviation rule and still lie. Names that borrow domain
  vocabulary (`blocker`, `critical`, `nitpick`, `error`, `warning`) must
  match the field's actual definition: a bucket holding `minor + info`
  findings named `nitpicks` is wrong, since minor issues are not
  necessarily trivial. Prefer a name keyed to the real boundary
  (`lowRiskCount` / `highRiskCount`). This is a **required gate**, not
  advisory — surface an inaccurate-name finding even when formatting is
  clean.

## Apply or Report

- **Auto-fixable** (mechanical) → apply silently, note in the commit message.
- **Requires judgment** → surface as a suggestion before committing: what the
  finding is, where, and a concrete fix sketch.
- **Conflicts with project config** → suppress; never fight the linter.

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn workstyle-naming`).
