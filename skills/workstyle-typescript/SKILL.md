---
name: wk-workstyle-typescript
description: >-
  Use when writing or editing TypeScript or JavaScript (.ts/.tsx/.js/.jsx/.mjs/.cjs) — enforces const-over-let and no var, no any (use unknown and narrow), explicit public return types, arrow callbacks, nullish coalescing over ||, optional chaining, destructuring, and Promise.all for independent async. Auto-invoked whenever the agent touches a TS/JS file. Project tsconfig/eslint/prettier config wins.
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

# Workstyle — TypeScript / JavaScript

Enforces idiomatic, type-safe TypeScript and JavaScript on every file the agent
writes or edits. Part of the `wk-workstyle` family. **Project settings are
authoritative — this skill fills gaps only, never overrides.** When a
linter/formatter config governs a rule below, that config wins; see
`wk-workstyle` Step 0 for the project-style-authority probe.

## When to Use

Auto-invoked whenever the agent writes or edits a TypeScript or JavaScript file.
Trigger contexts:

- Writing or editing a `.ts`, `.tsx`, `.js`, `.jsx`, `.mjs`, or `.cjs` file.
- Authoring or refactoring functions, callbacks, or async flows in any of the
  above file types.
- Introducing defaulting, null-guarding, or object-field access in TS/JS code.

Manual: `/wk-workstyle-typescript scan` (full working tree) · `/wk-workstyle-typescript check <path>` (one file).

## Rules

- **`const` over `let`; never `var`.**
- **No `any` in TypeScript.** Use `unknown` when the type is
  genuinely unknown; narrow before using. `any` defeats the type
  system.
- **Explicit return types on public functions.** TypeScript inference
  is not documentation.
- **Arrow functions for callbacks; named functions for top-level
  declarations.** Anonymous `function` expressions → arrow unless
  `this` binding is needed.
- **Nullish coalescing (`??`) over `||`** for defaulting — `||`
  treats `0`, `""`, `false` as missing.
- **Optional chaining (`?.`) over guard chains** (`x && x.y && x.y.z`).
- **Destructure at the call site** when using ≥ 3 fields from an object.
- **`Promise.all` for independent async operations;** never sequential
  `await` when operations don't depend on each other.

## Apply or Report

- **Auto-fixable** (mechanical) → apply silently, note in the commit message.
- **Requires judgment** → surface as a suggestion before committing: what the
  finding is, where, and a concrete fix sketch.
- **Conflicts with project config** → suppress; never fight the linter.

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn workstyle-typescript`).
