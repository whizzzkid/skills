---
name: wk-workstyle-async
description: >-
  Use when writing or editing asynchronous or concurrent code — promises,
  async/await, callbacks, .then chains, goroutines, threads, channels, mutexes.
  Forbids temporal coupling between concurrent operations, unbounded promise
  chains, and silently swallowed async errors. Auto-invoked whenever the agent
  touches async or concurrent code. Project linter config wins.
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

# Workstyle — Async & Concurrency

Enforces safe asynchronous and concurrent patterns for every promise, await,
callback, goroutine, thread, channel, and mutex the agent writes. Part of the
`wk-workstyle` family. **Project settings are authoritative — this skill fills
gaps only, never overrides.** When a linter/formatter config governs a rule
below, that config wins; see `wk-workstyle` Step 0 for the
project-style-authority probe.

## When to Use

Auto-invoked whenever the agent touches async or concurrent code. Trigger
contexts:

- Writing or editing `async`/`await` functions.
- Creating or modifying promises or `.then()`/`.catch()` chains.
- Passing or invoking callbacks for deferred or asynchronous work.
- Spawning goroutines or starting threads.
- Reading from or writing to channels.
- Acquiring, releasing, or guarding state with mutexes or other locks.

Manual: `/wk-workstyle-async scan` (full working tree) · `/wk-workstyle-async check <path>` (one file).

## Rules

- **No temporal dependencies between async calls.** Do not rely on
  one concurrent operation having completed by the time another
  reads its result unless the dependency is explicit (await, join,
  channel, mutex). Temporal coupling is a race condition waiting to
  surface.
- **No unbounded async chaining.** `.then().then().then()` > 2
  levels → extract named async function and `await` each step.
  Chains obscure error provenance and break stack traces.
- **Propagate errors from async operations.** Never `.catch(() => {})`
  silently. At minimum log and re-throw. If ignoring the error is
  intentional, leave a one-line comment saying why.

## Apply or Report

- **Auto-fixable** (mechanical) → apply silently, note in the commit message.
- **Requires judgment** → surface as a suggestion before committing: what the
  finding is, where, and a concrete fix sketch.
- **Conflicts with project config** → suppress; never fight the linter.

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn workstyle-async`).
