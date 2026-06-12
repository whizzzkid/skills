---
name: wk-workstyle-error-handling
description: >-
  Use when writing or editing error-handling code — catch/rescue/except blocks,
  error returns, raising or throwing exceptions. Forbids silently swallowed
  errors (empty catch blocks) and requires distinguishing operational errors
  (handle gracefully) from programmer errors (fail fast). Auto-invoked whenever
  the agent touches an error path. Project linter config wins.
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
  version: '2026.06.12-021635'
  internal: false
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Workstyle — Error Handling

Enforces robust error handling on every error path the agent writes — no
silently swallowed errors, and a clear split between operational and programmer
errors. Part of the `wk-workstyle` family. **Project settings are authoritative
— this skill fills gaps only, never overrides.** When a linter/formatter config
governs a rule below, that config wins; see `wk-workstyle` Step 0 for the
project-style-authority probe.

## When to Use

Auto-invoked whenever the agent touches an error path. Trigger contexts:

- Writes or edits a `catch`/`rescue`/`except` block.
- Writes or edits an error return.
- Writes code that raises or throws an exception.

Manual: `/wk-workstyle-error-handling scan` (full working tree) · `/wk-workstyle-error-handling check <path>` (one file).

## Rules

- **Never swallow errors silently.** Every `catch`/`rescue`/`except`
  must log, re-raise, or translate into a domain-specific error.
  Empty catch blocks are always a finding.
- **Distinguish operational errors from programmer errors.** Operational
  (network timeout, file not found) → handle gracefully.
  Programmer (null passed where required) → throw hard, fail fast.

## Apply or Report

- **Auto-fixable** (mechanical) → apply silently, note in the commit message.
- **Requires judgment** → surface as a suggestion before committing: what the
  finding is, where, and a concrete fix sketch.
- **Conflicts with project config** → suppress; never fight the linter.

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn workstyle-error-handling`).
