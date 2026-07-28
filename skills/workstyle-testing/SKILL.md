---
name: wk-workstyle-testing
description: >-
  Tests for a code change — requires coverage of every new function/branch,
  behavioral (not implementation) assertions, sad-path tests for every error
  branch. Complements wk-testing-skeleton (which frames the plan) by enforcing
  the quality gate. Auto-invoked on any test edit; project linter wins.
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
  version: "2026.07.28-171127"
  internal: false
  model:
    openai: gpt-5.6-luna
    google: gemini-2.5-flash
    meta: llama-4-scout
    kimi: k2
    qwen: qwen3-30b
    cursor: composer-2
---

# Workstyle — Testing Intent

Enforces the test quality bar for every test the agent writes or edits —
new-path coverage, behavioral assertions, and mandatory sad-path tests. Part of
the `wk-workstyle` family. **Project settings are authoritative — this skill
fills gaps only, never overrides.** When a linter/formatter config governs a
rule below, that config wins; see `wk-workstyle` Step 0 for the
project-style-authority probe.

## When to Use

Auto-invoked whenever the agent writes or modifies any test. Trigger contexts:

- Adding tests for a new feature or newly introduced function/branch.
- Writing a regression test for a bugfix.
- Adding or updating tests to verify a refactor preserved behavior.
- Adding sad-path / error-handling coverage.

Relationship to `wk-testing-skeleton`: that skill frames the test *plan*
(behavioral over structural, happy + sad paths, mutation check); this skill is
the quality *gate* that confirms the written tests meet the bar. They are
complementary — invoke testing-skeleton when planning, this when reviewing
written tests.

Manual: `/wk-workstyle-testing scan` (full working tree) · `/wk-workstyle-testing check <path>` (one file).

## Rules

- **Cover new lines.** For every function or branch added in the
  diff, ask: does a test exercise this path? If the answer is no
  and the code is non-trivial, add a test. Exceptions: one-off
  scripts, migration runners, CLI entry-point scaffolding, trivial
  delegators that are covered transitively.
- **Tests assert behavior, not implementation.** Avoid tests that
  assert internal state or private method calls. Test the
  observable outcome.
- **Shape assertions never prove a feature works.** Asserting a
  config/data value equals an expected literal proves the input
  *looks* right, not that the parse → lookup → compare path runs — it
  still passes with a wrong lookup key, type mismatch, or comparison
  bug. To validate a feature works, drive it end-to-end through its
  real entry point (HTTP request, public method) against real values,
  with no stub of the path under test (e.g. `and_call_original`),
  asserting the observable outcome plus a negative case. Reserve
  structural/shape assertions for genuine schema-contract tests, never
  as a proxy for "it works."
- **Sad-path tests are mandatory** for any error-handling branch.
  A function that throws/returns-error with no corresponding test
  is untested error handling.

## Apply or Report

- **Auto-fixable** (mechanical) → apply silently, note in the commit message.
- **Requires judgment** → surface as a suggestion before committing: what the
  finding is, where, and a concrete fix sketch.
- **Conflicts with project config** → suppress; never fight the linter.

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn workstyle-testing`).
