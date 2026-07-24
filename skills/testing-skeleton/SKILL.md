---
name: wk-testing-skeleton
description: >-
  Frames how the agent writes tests for any code change — biases toward
  behavioral over structural tests, requires happy+sad paths and mutation
  verification, treats coverage as a lagging indicator. Auto-invoked
  whenever the agent writes, adds, or modifies tests. Feeds wk-workflow
  Phase 3.
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
  version: '2026.07.24-224247'
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

- Tests prove **behavior**, not **structure**.
- Runs before any test is written → produces a plan biased toward behavioral coverage of every meaningful path → verifies tests via mutation.
- Coverage % is a lagging indicator, never the target.

```
Trigger ──► Classify the change ──► Plan paths
                                       (happy + sad + edge, behavioral first)
                                       │
                                       ▼
                                    Write tests ──► Mutate to verify ──► Hand off to Phase 3
```

---

## Hard Rules

1. **Behavioral tests are the default.** Observe inputs/outputs across the unit's public boundary — only kind that proves the code does what it claims.
2. **Structural tests are a last-resort fallback.** "Function X is called" / "method Y exists" / "class Z inherits W" pins the implementation → refactors expensive, bugs still undetectable.
3. **Every change covers happy AND sad paths.** Happy proves it can succeed; sad proves it fails the way it claims. One without the other is half a test.
4. **Every new behavioral test gets mutation-verified.** A test that doesn't fail on a broken impl is decorative. Property-based and snapshot tests are exempt — the framework fuzzes or diffs for you.
5. **Coverage % is a lagging indicator.** Never write a test to raise a number; never skip a path because the number is already high.
6. **Baseline the suite before appending tests.** Run an existing test file and confirm it passes before adding to it. If already failing → fix the pre-existing failure first, or put new tests in a standalone file. Appending to a broken suite gives false confidence: new tests appear to fail from broken setup, masking whether new code is tested.

---

## Behavioral vs structural — the dividing line

**Behavioral** when:

- Calls the unit through its public interface (function args, HTTP request, CLI invocation, message send).
- Asserts on **observable output** (return value, response body, emitted message, side effect on a real-or-fake collaborator at the boundary).
- Still passes after a clean rewrite of internals that preserved the contract.

**Structural** when:

- Asserts on internal implementation details — private method calls, intermediate variables, mock-call counts on stubs representing collaborators inside the unit's boundary.
- Fails on a behavior-preserving refactor (rename a private helper, swap a `for` loop for a `map`, inline a variable).
- Verifies "the code is shaped this way" rather than "the code does this thing."

When in doubt: **if I rewrote this function from scratch keeping its contract, would the test still pass?** Yes → behavioral. No → structural.

---

## Stage 0: Detect the change kind

Classify what's being tested before writing any test — plan shape depends on the kind.

| Change kind | Detect via | Test focus |
|-------------|------------|------------|
| **New feature / function** | Net-new file or symbol | Full happy/sad matrix + edge cases for every input axis |
| **Bug fix** | Diff fixes a reported behavior; usually has a linked issue | **Regression test first** — the test that would have caught this bug. Then re-confirm happy paths still hold. |
| **Refactor** (no behavior change) | Same external contract, different internals | Existing behavioral tests must pass unchanged. If they don't, either the refactor changed behavior (revert/scope) or the existing tests were structural (rewrite them behaviorally). |
| **Performance / observability change** | Same correctness, different runtime/output | Behavioral correctness still proven; add a perf assertion or metric assertion as appropriate. |
| **Pure deletion** | Removed code with no replacement | Remove only the tests that exercised the deleted contract; never delete tests that still exercise live code. |

---

## Stage 1: Map the paths

Enumerate every meaningful path through the unit's public contract. Every path becomes a test.

### Happy paths

- Expected, documented success cases — one per distinct successful outcome shape, not one overall.
- Different success shapes for different inputs (empty list vs populated, found vs not-found-but-not-an-error) → each gets its own happy-path test.

### Sad paths

- Every documented failure mode — invalid input, missing data, upstream failure, permission denied, conflict, rate limit.
- Every error type the contract can raise/return → a test that triggers it and asserts the right error type/code/message.

### Edge cases

- Boundary values: empty / single / many; min / max / off-by-one.
- Null-equivalents: `null`, `undefined`, `None`, `nil`, missing field, empty string vs absent string.
- Concurrent / ordering: stale read, double-call, cancellation, reentrancy.
- Type confusion: values that satisfy the type but violate the semantic contract (negative age, future birth date, email without `@`).
- Format validators (character-set / regex / schema checks): derive the allowed set from **real example values** in the codebase, spec, or upstream docs — not intuition. Grep representative inputs of the format under test; assert each character/token in those examples passes the validator. Intuition-written validators routinely reject legal-but-uncommon characters (e.g., `:` in a versioned identifier) that real inputs require.

### Path-coverage check

List the paths before writing tests and confirm:

- Every documented success case is covered.
- Every documented failure case is covered.
- At least one edge case per input axis (lists, strings, numbers, optional fields).

Any uncovered axis → **add the path** before writing any test. The plan is the contract; coverage% is the receipt.

---

## Stage 2: Choose test type per path

Default to **unit + behavioral**. Escalate to integration only when behavior cannot be observed without a real collaborator (database query semantics, HTTP framing, file system races).

| Test type | When to use |
|-----------|-------------|
| **Behavioral unit test** | Default. The unit's contract is observable through its public interface; collaborators can be replaced with real-or-fake doubles at the boundary. |
| **Integration test** | The behavior under test depends on a real collaborator's semantics (DB query plan, HTTP/2 framing, OS scheduler). Use sparingly — slower and harder to localize failures. |
| **Property-based test** | The unit has invariants that should hold across input space (sort produces sorted output; encode/decode roundtrips; serializers are idempotent). One property test replaces dozens of example tests. |
| **Snapshot / golden test** | Output is large and structured (rendered HTML, generated SQL, AST). Useful only when reviewers will actually inspect snapshot diffs; otherwise becomes change-detection theater. |
| **Structural test** | **Last resort only.** Use only when behavior cannot be observed at all (e.g., asserting that a side-effecting hook was registered with the framework, when the framework has no observable side effect to test through). Document why behavioral was impossible. |

If the plan picks structural for any path, write a one-line comment in the test file naming the unavailable behavioral observation: `# structural: framework provides no hook to observe registration; refactor target.`

---

## Stage 3: Write the tests

Write each planned path as a behavioral observation:

- **Arrange:** set up inputs and the boundary state the test needs.
- **Act:** call the unit through its public interface.
- **Assert:** check observable outputs / state changes / emitted events.

Avoid:

- **Mocking inside the unit's boundary.** Replace collaborators only at process boundaries (network, disk, clock). Mocking internals turns the test structural.
- **Mock-call-count as primary assertion.** "Called with X" is structural; "produced output Y" is behavioral. Assert emitted record shape, not logger call count.
- **One mega-test that exercises everything.** One test = one observable claim. Multi-claim tests fail uninformatively.
- **Assertions on private state.** If the test needs a private field, the public observation surface is too narrow — expand it or skip the assertion.

Match the project's existing test framework, file layout, and naming convention. `wk-format` runs alongside; defer to its style rules.

### Fixtures match the full expected schema

When the unit consumes a structured payload (JSON, API response, hash, dataclass), the fixture must include every field the schema requires — not just the subset the current test exercises.

- Read the schema from production code paths, an OpenAPI/JSON-Schema spec, or other passing tests in the suite. Use those as the minimum field set in every new fixture.
- Minimal stubs (only the fields the current assertion touches) create hidden coupling: when another code path on the same struct branches on a previously-unused field, every test using the minimal fixture starts asserting on undefined behavior or crashing on `fetch`/key-access of the missing field.
- Property-based / generated fixtures must constrain by the same schema; a randomized hash without required fields is no safer than a handwritten minimal one.

### Match message-expectation cardinality to the call's fan-out

A bare `expect(...).to receive(:method)` (RSpec) carries an implicit `.once`;
single-call defaults exist in most mock frameworks. When the method under test
invokes that collaborator once per iterated input (per key, per record, per
field), the real count is data-dependent and the implicit `.once` false-fails
("expected 1 time, received N") even though the behavior is correct.

- For any collaborator the code can call more than once — anything inside a loop
  or once per input — assert `.at_least(:once)` or an explicit count matched to
  the fan-out, never the bare single-call default.
- A shared sink (error tracker, logger, metrics) hit once per element is the
  common trap: the fixture's input size silently sets the expected count.

### Verify the error string before coding a fallback that catches it

When writing a fallback that discriminates on a specific tool error message (`if stderr matches "X" then fall back`), run the failing command against a real-enough environment first to capture the exact wording.

- Error wording differs across tool versions and platforms; a guessed string makes the fallback either never fire or swallow unrelated failures.
- Corollary of the "probe capability, don't parse error text" rule in `wk-workstyle`: if you must match on error text, derive it from observation, not intuition.
- For git network errors, use `file://` URIs to activate the network code path in a local test instead of bare paths (which use the local protocol and emit different errors).

### Capture args inside the loop in fake shell-binary stubs

When a fake binary (a stub `curl`/`git`/etc. on `PATH`) logs its invocation by
parsing positional args in a `while [[ $# -gt 0 ]]; do ... shift; done` loop,
`echo "$@"` placed **after** the loop always emits nothing — `shift` consumes
`$@` in place, so it is empty once the loop exits. The log file is never written
and tests fail with a missing-file error instead of a useful assertion.

- Capture the value into a named variable **inside** the loop (e.g. `api_url="$1"`
  in the wildcard `case` branch), then read that variable after the loop.
- Never rely on `$@` / `$1` surviving a complete shift-consuming loop.

### Pass harness payloads through the environment, never string interpolation

A fixture that interpolates the input under test into a shell command string
cannot represent input containing a quote character — the input's own quote closes
the wrapping quote and silently mangles the payload before the artifact ever sees it.

- Export the payload and read it inside the child process instead of building the
  command text around it: `PAYLOAD=… run bash -c 'printf %s "$PAYLOAD" | "$1"' _ "$TOOL"`.
- The corruption fails open-looking — the case reports a plausible assertion failure
  rather than an error, so it reads as evidence about the code, not about the fixture.
- A newly added case failing while every pre-existing case passes indicts the harness
  first: re-run the same input against the artifact directly before changing the
  implementation. Disagreement means the fixture is the defect.

### Assert a literal tilde with a quoted glob, not a regex

An unquoted leading `~` on the right of a bash `[[ =~ ]]` is tilde-expanded to
`$HOME` before the regex runs, so a pattern meant to match a literal tilde — or a
tilde-prefixed home path (a yarnrc dotfile, say) — instead matches the expanded
`$HOME` value, and the assertion passes or fails for the wrong reason.

- Assert a literal-tilde string with a quoted glob so no expansion happens:
  `[[ "$output" == *'~'* ]]`; quote any tilde-prefixed path segment the same way.
- When the substring can match a superset, add a negative assertion excluding it.

### Nil-out consumed env vars in stubbed-ENV tests

When a test replaces the process environment (e.g., `stub_const("ENV", ENV.to_h.merge(...).compact)` in RSpec, `monkeypatch.setenv` / `delenv` in pytest, equivalent harness patterns elsewhere), explicitly set every env var the code under test reads — including the ones the test does NOT want set — to `nil` / absent in the stub.

- Grep the code under test for every `ENV[...]`, `ENV.fetch(...)`, `os.environ[...]`, `process.env.X` call. Each must appear in the stub with a chosen value or explicitly `nil`.
- `.compact` (or equivalent) strips `nil` entries from the stub. With `.compact`, "not in the hash" means "read from the real environment" — exactly the CI-leakage trap. Either keep the `nil` entries without compacting, or use the framework's `delete_env` API explicitly.
- Local pass + CI fail with messages like "expected nil, got URL" or "expected nil, got <token>" is the canonical signature of this leak — CI runners inject `BUILDKITE_*`, `GITHUB_*`, `CI`, `RUNNER_*`, and similar vars the local shell does not.

### Restore shared/global state a test mutates

A test that mutates process- or framework-level shared state (redraws a web framework's route table, monkeypatches a class method, swaps a global registry/singleton) leaks that mutation into every test that runs after it unless it explicitly restores the original in an `after`/teardown hook.

- The failure is order-dependent: the mutating test passes alone, and the polluted tests fail only when run after it — the signature is unrelated tests failing after a suite reorder or a new nearby test.
- Standard test-runner isolation (transactional DB rollback, per-example object doubles) does not cover state a test explicitly replaces at the module/class/framework level — pair every such mutation with an explicit restore.
- Rails example: a controller spec calling `routes.draw` to register a probe route must restore the real table afterward (`after { Rails.application.reload_routes! }`) — otherwise later request specs 404 against the stripped table.

### Roll back or re-prepare after an ad-hoc probe

An interactive verification script run through the framework's runner against the test database is a state mutation with no safety net: runners **commit by default**, unlike the spec suite, which wraps each example in a rolled-back transaction.

- Wrap every probe in an explicit always-rollback transaction, or re-prepare the test database immediately after the probe and before the next suite run.
- Treat an unexplained failure in a spec the current change does not touch as self-inflicted state pollution **first**, not a regression — leftover rows are indistinguishable from a fixture the suite never created, so the phantom failures read as real ones.
- The rule covers any out-of-suite write path (console session, seed script, one-off migration), not only a runner invocation.

---

## Stage 4: Mutation verification

A new test is decorative until seen failing on a broken implementation. After each test (or batch):

1. **Mutate the implementation** in a small, targeted way:
   - Flip a conditional (`<` → `<=`).
   - Hardcode a return value.
   - Remove a validation check.
   - Swap two arguments in a sub-call.
   - Replace `+` with `-`, `&&` with `||`.
2. **Run the test.** It must fail.
3. **Restore the implementation.**

A contract-breaking mutation that breaks no test → the suite has a hole. Add the missing assertion before moving on.

For changes shipping > ~5 new tests, batch the pass: make 3-5 different mutations, run the suite, confirm each fails at least one test. Mutations that fail nothing point at a missing test or a structural one that doesn't observe behavior.

**Required for every new behavioral test.** Two exemptions:
- **Property-based tests** — the fuzzer/shrinker performs the mutation step automatically.
- **Snapshot tests** — the snapshot diff is the verification mechanism.

---

## Stage 5: Coverage as receipt, not target

After tests pass and mutations verify, **then** look at coverage — as a check that Stage 1's path map was honored, not as a goal:

- **Uncovered branches** → path map missed something (add a test) or the branch is unreachable (remove/refactor the dead code).
- **Already-covered branches** → fine. Do not write redundant tests to inflate the number.
- **CI coverage gates** → respect them, but solve failures by finding the missing path, not by writing structural tests that touch lines without observing behavior.

Coverage tools count line execution, not assertion quality. A 100%-covered file with no sad-path assertions is worse-tested than a 70%-covered file with full happy/sad behavioral coverage.

---

## Coordination with other skills

- **`wk-workflow` Phase 3 (Test):** testing-skeleton runs first and produces the plan; Phase 3 verifies the suite passes (lint, type, full suite). Phase 3's "happy/sad/edge" requirement is the same shape as Stage 1 here.
- **`wk-format`:** test files are code — formatting rules apply identically.
- **`wk-commit`:** test additions ship with their own commit (preferred), or alongside the implementation in a single commit with the `🧪` classifier emoji when tests + impl are inseparable.
- **`wk-pr-review` Phase 4:** the playground's mutation step is the same idea applied to *someone else's* tests. The plan produced here is what the reviewer checks against.

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
