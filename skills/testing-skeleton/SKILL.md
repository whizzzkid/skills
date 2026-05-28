---
name: wk-testing-skeleton
description: >-
  Frames how the agent writes tests for any code change. Auto-invoked
  whenever the agent is about to write, add, or modify tests — new
  features, bug fixes, refactors, regression coverage. Biases the test
  plan toward behavioral tests over structural ones, requires both happy
  and sad paths, requires mutation verification of new tests, and treats
  coverage as a lagging indicator rather than a goal. Structural tests
  are a last-resort fallback, not a default. Integrates with `wk-workflow`
  Phase 3 (Test) — testing-skeleton produces the plan, Phase 3 verifies
  the suite passes.
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - AskUserQuestion
  - Write
model: sonnet
effort: medium
model-invocable: true
user-invocable: false
license: MIT
group: workflows
metadata:
  author: whizzzkid
  version: '2026.05.28-201600'
  internal: false
  model:
    openai: gpt-4.1
    google: gemini-2.5-pro
    meta: llama-4-maverick
    kimi: k2
    qwen: qwen3-235b
    cursor: composer-2
---

# Testing Skeleton

Tests prove the code's **behavior**, not its **structure**. The skill
runs before any test is written and produces a plan that biases
toward behavioral coverage of every meaningful path, then verifies
the resulting tests via mutation. Coverage percentage is a lagging
indicator — never the target.

```
Trigger ──► Classify the change ──► Plan paths
                                       (happy + sad + edge, behavioral first)
                                       │
                                       ▼
                                    Write tests ──► Mutate to verify ──► Hand off to Phase 3
```

---

## Hard Rules

1. **Behavioral tests are the default.** Tests that observe inputs
   and outputs across the public boundary of the unit under change
   are the only kind that prove the code does what it claims.
2. **Structural tests are a last-resort fallback.** Tests that
   assert "function X is called" / "method Y exists" / "class Z
   inherits from W" do not prove behavior — they pin the
   implementation, making refactors expensive without making bugs
   detectable.
3. **Every change covers happy AND sad paths.** A passing happy
   path proves the code can succeed; a passing sad path proves the
   code fails the way it claims to. One without the other is half
   a test.
4. **Every new behavioral test gets mutation-verified.** A test that doesn't fail
   when the implementation is broken is decorative. Property-based and snapshot
   tests are exempt — the framework fuzzes or diffs for you.
5. **Coverage % is a lagging indicator.** Never write a test to
   raise a number; never skip a path because the number is already
   high.
6. **Baseline the suite before appending tests.** Before adding tests
   to an existing test file, run the file and confirm it currently
   passes. If it is already failing, fix the pre-existing failure
   first or place new tests in a standalone file. Appending to a
   broken suite gives false confidence — your tests appear to fail
   when the setup is broken, masking whether the new code is
   actually tested.

---

## Behavioral vs structural — the dividing line

A test is **behavioral** when:

- It calls the unit through its public interface (function args,
  HTTP request, CLI invocation, message send).
- It asserts on **observable output** (return value, response body,
  emitted message, side effect on a real-or-fake collaborator at
  the boundary).
- It would still pass after a clean rewrite of the internals that
  preserved the contract.

A test is **structural** when:

- It asserts on internal implementation details — private method
  calls, intermediate variables, mock-call counts on stubs that
  represent collaborators inside the unit's boundary.
- It would fail on a refactor that didn't change behavior (rename
  a private helper, swap a `for` loop for a `map`, inline a
  variable).
- It primarily verifies that "the code is shaped this way" rather
  than "the code does this thing."

When in doubt, ask: **if I rewrote this function from scratch
keeping its contract, would the test still pass?** If yes →
behavioral. If no → structural.

---

## Stage 0: Detect the change kind

Before writing any test, classify what's being tested. The plan
shape depends on the kind.

| Change kind | Detect via | Test focus |
|-------------|------------|------------|
| **New feature / function** | Net-new file or symbol | Full happy/sad matrix + edge cases for every input axis |
| **Bug fix** | Diff fixes a reported behavior; usually has a linked issue | **Regression test first** — the test that would have caught this bug. Then re-confirm happy paths still hold. |
| **Refactor** (no behavior change) | Same external contract, different internals | Existing behavioral tests must pass unchanged. If they don't, either the refactor changed behavior (revert/scope) or the existing tests were structural (rewrite them behaviorally). |
| **Performance / observability change** | Same correctness, different runtime/output | Behavioral correctness still proven; add a perf assertion or metric assertion as appropriate. |
| **Pure deletion** | Removed code with no replacement | Remove only the tests that exercised the deleted contract; never delete tests that still exercise live code. |

---

## Stage 1: Map the paths

For the unit under change, enumerate every meaningful path through
its public contract. Every path becomes a test.

### Happy paths

- The expected, documented success cases — one per distinct
  successful outcome shape, not just one overall.
- If the function returns different success shapes for different
  inputs (e.g., empty list vs populated list, found vs not-found
  but-not-an-error), each gets its own happy path test.

### Sad paths

- Every documented failure mode — invalid input, missing data,
  upstream failure, permission denied, conflict, rate limit.
- Every error type the contract says the unit can raise/return
  must have a test that triggers it and asserts the right
  error type/code/message.

### Edge cases

- Boundary values: empty / single / many; min / max / off-by-one.
- Null-equivalents: `null`, `undefined`, `None`, `nil`, missing
  field, empty string vs absent string.
- Concurrent / ordering: stale read, double-call, cancellation,
  reentrancy.
- Type confusion: pass values that satisfy the type but violate
  the semantic contract (negative age, future birth date, email
  without `@`).
- Format validators (character-set / regex / schema checks):
  derive the allowed set from **real example values** found in the
  codebase, spec, or upstream docs — not from intuition. Grep for
  representative inputs of the format under test and assert each
  character / token in those examples passes the validator. Validators
  written from intuition routinely reject legal-but-uncommon characters
  (e.g., `:` in a versioned identifier) that real inputs require.

### Path-coverage check

Before writing tests, list the paths and confirm:

- Every documented success case is covered.
- Every documented failure case is covered.
- At least one edge case per input axis (lists, strings, numbers,
  optional fields).

If any axis is uncovered, **add the path** before writing any
test. The plan is the contract — coverage% is the receipt.

---

## Stage 2: Choose test type per path

Default to **unit + behavioral**. Escalate to integration only when
the unit's behavior cannot be observed without a real collaborator
(database query semantics, HTTP framing, file system races).

| Test type | When to use |
|-----------|-------------|
| **Behavioral unit test** | Default. The unit's contract is observable through its public interface; collaborators can be replaced with real-or-fake doubles at the boundary. |
| **Integration test** | The behavior under test depends on a real collaborator's semantics (DB query plan, HTTP/2 framing, OS scheduler). Use sparingly — slower and harder to localize failures. |
| **Property-based test** | The unit has invariants that should hold across input space (sort produces sorted output; encode/decode roundtrips; serializers are idempotent). One property test replaces dozens of example tests. |
| **Snapshot / golden test** | Output is large and structured (rendered HTML, generated SQL, AST). Useful only when reviewers will actually inspect snapshot diffs; otherwise becomes change-detection theater. |
| **Structural test** | **Last resort only.** Use only when behavior cannot be observed at all (e.g., asserting that a side-effecting hook was registered with the framework, when the framework has no observable side effect to test through). Document why behavioral was impossible. |

If the plan picks structural for any path, write a one-line
comment in the test file naming the behavioral observation that
was unavailable: `# structural: framework provides no hook to
observe registration; refactor target.`

---

## Stage 3: Write the tests

For each planned path, write the test as a behavioral observation:

- **Arrange:** set up inputs and the boundary state the test
  needs.
- **Act:** call the unit through its public interface.
- **Assert:** check observable outputs / state changes / emitted
  events.

Avoid:

- **Mocking inside the unit's boundary.** Replace collaborators only at process
  boundaries (network, disk, clock). Mocking internals turns the test structural.
- **Mock-call-count as primary assertion.** "Called with X" is structural;
  "produced output Y" is behavioral. Assert emitted record shape, not logger call count.
- **One mega-test that exercises everything.** One test = one observable claim.
  Multi-claim tests fail uninformatively.
- **Assertions on private state.** If the test needs a private field, the public
  observation surface is too narrow — expand it or skip the assertion.

Match the project's existing test framework, file layout, and
naming convention. `wk-format` runs alongside; defer to its rules
for style.

### Nil-out consumed env vars in stubbed-ENV tests

When a test replaces the process environment (e.g., `stub_const("ENV", ENV.to_h.merge(...).compact)` in RSpec, `monkeypatch.setenv` / `delenv` in pytest, equivalent harness patterns elsewhere), explicitly set every env var the code under test reads — including the ones the test does NOT want set — to `nil` / absent in the stub.

- Grep the code under test for every `ENV[...]`, `ENV.fetch(...)`, `os.environ[...]`, `process.env.X` call. Each must appear in the stub, either with a chosen value or explicitly `nil`.
- The `.compact` (or equivalent) step strips `nil` entries from the stub. With `.compact`, "not in the hash" means "read from the real environment" — which is exactly the CI-leakage trap. Either keep the `nil` entries in the stub hash without compacting, or use the framework's `delete_env` API explicitly.
- Local pass + CI fail with messages like "expected nil, got URL" or "expected nil, got <token>" is the canonical signature of this leak — CI runners inject `BUILDKITE_*`, `GITHUB_*`, `CI`, `RUNNER_*`, and similar vars that the local shell does not.

---

## Stage 4: Mutation verification

A new test is decorative until it has been seen failing on a
broken implementation. After each test (or batch) is written:

1. **Mutate the implementation** in a small, targeted way:
   - Flip a conditional (`<` → `<=`).
   - Hardcode a return value.
   - Remove a validation check.
   - Swap two arguments in a sub-call.
   - Replace `+` with `-`, `&&` with `||`.
2. **Run the test.** It must fail.
3. **Restore the implementation.**

If a mutation that breaks the contract did not break any test, the
test suite has a hole. Add the missing assertion before moving on.

For changes shipping with > ~5 new tests, batch the mutation pass:
make 3-5 different mutations, run the suite, confirm each mutation
fails at least one test. Mutations that fail nothing point at
either a missing test or a structural one that doesn't observe
behavior.

This step is **required for every new behavioral test.** Two exemptions:
- **Property-based tests** — the fuzzer/shrinker performs the mutation step automatically.
- **Snapshot tests** — the snapshot diff is the verification mechanism.

---

## Stage 5: Coverage as receipt, not target

After tests pass and mutations verify, **then** look at coverage —
as a check that the path map from Stage 1 was honored, not as a
goal:

- **Uncovered branches** → either the path map missed something
  (add a test) or the branch is unreachable (remove or refactor
  the dead code).
- **Already-covered branches** → fine. Do not write redundant
  tests to inflate the number.
- **Coverage gates from CI** → respect them, but solve gate
  failures by finding the missing path, not by writing
  structural tests that touch the lines without observing
  behavior.

Coverage tools count line execution; they do not count assertion
quality. A 100%-covered file with no sad-path assertions is
worse-tested than a 70%-covered file with full happy/sad
behavioral coverage.

---

## Coordination with other skills

- **`wk-workflow` Phase 3 (Test):** testing-skeleton runs first
  and produces the plan; Phase 3 verifies the resulting suite
  passes (lint, type, full suite). Phase 3's "happy/sad/edge"
  requirement is the same shape as Stage 1 here.
- **`wk-format`:** test files are code — formatting rules apply
  identically.
- **`wk-commit`:** test additions ship with their own commit
  (preferred) or alongside the implementation in a single commit
  with the `🧪` classifier emoji when tests + impl are
  inseparable.
- **`wk-pr-review` Phase 4:** the playground's mutation step is
  the same idea applied to *someone else's* tests. The plan
  produced here is what the reviewer will check against.

---

## Quick Reference

| Trigger | Stages |
|---------|--------|
| Agent about to write/modify any test | 0 → 5 |
| Bug fix | 0 (kind: bug fix) → regression test first → 1-5 |
| Refactor | 0 (kind: refactor) → existing tests must pass; rewrite structural ones behaviorally |
| New feature | 0 → 5 with full happy/sad/edge matrix |
| CI coverage gate failed | Stage 5 — find the missing path; never paper over with structural tests |

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument (e.g., `wk-learn testing-skeleton`).
