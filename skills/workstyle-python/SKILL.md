---
name: wk-workstyle-python
description: >-
  Use when writing or editing Python (.py) — enforces type hints on public
  functions, f-strings over .format()/%, dataclass/TypedDict for structured
  data, pathlib over os.path, context managers for resources, logging over
  print, and no mutable default arguments. Auto-invoked whenever the agent
  touches a .py file. Project ruff/black/mypy/pyproject config wins.
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

# Workstyle — Python

Enforces idiomatic, type-safe Python style on every `.py` file the agent
writes or edits. Part of the `wk-workstyle` family. **Project settings
are authoritative — this skill fills gaps only, never overrides.** When a
linter/formatter config governs a rule below, that config wins; see
`wk-workstyle` Step 0 for the project-style-authority probe.

## When to Use

Auto-invoked whenever the agent writes or edits a `.py` file. Trigger contexts:

- Creating, editing, or refactoring any `.py` file (modules, packages, scripts, tests).
- Adding or modifying function/method signatures, especially public ones.
- Introducing string interpolation, structured data bundles, or resource handling (files, sockets, locks, DB connections).
- Adding logging or diagnostic output, or replacing `print` calls.
- Reviewing function defaults for mutable-default-argument bugs.

Manual: `/wk-workstyle-python scan` (full working tree) · `/wk-workstyle-python check <path>` (one file).

## Rules

- **Type hints on all public functions** (PEP 484). Use `from __future__ import annotations` for forward refs.
- **f-strings** over `.format()` or `%` interpolation.
- **`dataclass` or `TypedDict`** for structured data bundles, not raw dicts.
- **`pathlib.Path`** over `os.path` string manipulation.
- **Context managers** for every resource that must be closed.
- **`logging`** over `print` for anything that isn't script output.
- **No mutable default arguments.** `def f(items=[])` → `def f(items=None)` with `items = items or []`.

## Apply or Report

- **Auto-fixable** (mechanical) → apply silently, note in the commit message.
- **Requires judgment** → surface as a suggestion before committing: what the
  finding is, where, and a concrete fix sketch.
- **Conflicts with project config** → suppress; never fight the linter.

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn workstyle-python`).
