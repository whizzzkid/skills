---
name: wk-workstyle-error-handling
description: >-
  Error-handling code — catch/rescue/except, error returns, raise/throw.
  Forbids silently-swallowed errors (empty catch); requires distinguishing
  operational errors (handle gracefully) from programmer errors (fail fast),
  a raise-to-retry path specified and tested via the code's own
  retry/exhaustion hooks, and a fail-open promise held by a call-site rescue
  with a spec that stubs a raise. Auto-invoked on any error path; project
  linter wins.
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
  version: "2026.11.28-054738"
  internal: false
  model:
    openai: gpt-5.6-luna
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
- Writes a call promising a failure never blocks its caller (fail-open,
  best-effort, "never blocks the deploy").

Manual: `/wk-workstyle-error-handling scan` (full working tree) · `/wk-workstyle-error-handling check <path>` (one file).

## Rules

- **Never swallow errors silently.** Every `catch`/`rescue`/`except`
  must log, re-raise, or translate into a domain-specific error.
  Empty catch blocks are always a finding.
- **Distinguish operational errors from programmer errors.** Operational
  (network timeout, file not found) → handle gracefully.
  Programmer (null passed where required) → throw hard, fail fast.
- **HARD RULE — a raise meant to trigger downstream handling (retry,
  requeue, dead-letter, error mapping) is defined by the code's own
  class-dispatching hooks, not the framework default.** Before writing it:
  1. Grep the enclosing class and its ancestors for every hook that
     branches on exception class (retry-delay/backoff, retries-exhausted,
     rescue/error-mapping handlers); add an explicit branch for the new class.
  2. Spec each hook directly with the new class — total retry window and
     exhaustion outcome — not only that the raise fires.
  3. Comments state the window and terminal outcome those hooks produce;
     never "retries until it can".
  (An unbranched class falls to the default — a short window, then the dead
  queue — while a raise-only spec stays green.)
- **A fail-open ("never blocks the caller") promise is held by a rescue at
  the call site, not by checking the returned result.**
  1. Wrap the whole dependency interaction — construction, call, result
     handling — in one rescue of the standard error base (Ruby
     `StandardError`, Python `Exception`, JS `catch`); log what it caught.
  2. Never rescue signals or exit (`Exception` in Ruby, `BaseException` in
     Python) — an interrupt must still stop the process.
  3. Never rely on the dependency's own internal rescue: a raise from its
     constructor, or from an API renamed in a later version, escapes it.
  4. Spec a stubbed *raise* from the dependency next to the returned-failure
     stub, and assert the caller completes.
  Inside that wrapper the promise outranks fail-fast for programmer errors.
  (A result-only check and a result-only stub encode the same assumption;
  both stay green while one raise aborts the caller.)

## Apply or Report

- **Auto-fixable** (mechanical) → apply silently, note in the commit message.
- **Requires judgment** → surface as a suggestion before committing: what the
  finding is, where, and a concrete fix sketch.
- **Conflicts with project config** → suppress; never fight the linter.

## Post-Completion

Invoke `wk-learn workstyle-error-handling`.
