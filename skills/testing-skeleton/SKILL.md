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
  version: "2026.10.09-184159"
  internal: false
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-pro
    meta: llama-4-maverick
    kimi: k2
    qwen: qwen3-235b
    cursor: composer-2
---

# Testing Skeleton

Run before writing any test: classify the change → plan paths (happy + sad + edge, behavioral first) → write tests →
mutate to verify → hand off to `wk-workflow` Phase 3.

## Hard Rules

1. **Behavioral tests are the default.** Observe inputs/outputs across the unit's public boundary.
2. **Structural tests are a last-resort fallback.** "X is called" / "Y exists" / "Z inherits W" pins the implementation:
   refactors get expensive, bugs stay undetectable.
3. **Every change covers happy AND sad paths.** One without the other is half a test.
4. **Every new behavioral test gets mutation-verified.** A test that doesn't fail on a broken impl is decorative.
   Exempt: property-based and snapshot tests (the framework fuzzes or diffs for you).
5. **Coverage % is a lagging indicator.** Never write a test to raise a number; never skip a path because the number is
   already high.
6. **Baseline the suite before appending tests.** Run the existing test file and confirm it passes before adding to it;
   if already failing, fix the pre-existing failure first or put new tests in a standalone file. Never append to a
   broken suite: broken setup masks whether new code is tested.

## Behavioral vs structural

- Behavioral: calls the unit through its public interface (args, HTTP request, CLI, message); asserts on observable
  output (return value, response body, emitted message, side effect on a real-or-fake boundary collaborator); survives a
  clean rewrite of internals.
- Structural: asserts on private method calls, intermediate variables, or mock-call counts on collaborators inside the
  boundary; fails on a behavior-preserving refactor (rename a private helper, `for` → `map`, inline a variable).
- Tie-breaker: if you rewrote the function from scratch keeping its contract, would the test still pass? Yes →
  behavioral; no → structural.

## Stage 0: Classify the change

Classify before writing any test; the plan shape depends on it.

- **New feature / function** (net-new file or symbol): full happy/sad matrix + edge cases for every input axis.
- **Bug fix** (fixes reported behavior, usually a linked issue): **regression test first** — the one that would have
  caught the bug — then re-confirm happy paths.
- **Refactor** (same contract, new internals): existing behavioral tests must pass unchanged; if they don't, either the
  refactor changed behavior (revert/scope) or the tests were structural (rewrite them behaviorally).
- **Performance / observability** (same correctness, different runtime/output): still prove behavioral correctness; add
  a perf or metric assertion as appropriate.
- **Pure deletion**: remove only tests that exercised the deleted contract; never delete tests that still exercise live
  code.

## Stage 1: Map the paths

Enumerate every meaningful path through the public contract; every path becomes a test.

- **Happy:** one test per distinct success outcome shape (empty vs populated, found vs not-found-but-not-an-error), not
  one overall.
- **Sad:** every documented failure mode (invalid input, missing data, upstream failure, permission denied, conflict,
  rate limit); every error type the contract can raise/return gets a test asserting the right type/code/message.
- **Edge:**
  - Boundaries: empty / single / many; min / max / off-by-one.
  - Null-equivalents: `null`, `undefined`, `None`, `nil`, missing field, empty vs absent string.
  - Concurrency / ordering: stale read, double-call, cancellation, reentrancy.
  - Type confusion: type-valid but semantically invalid (negative age, future birth date, email without `@`).
  - Format validators (charset / regex / schema): derive the allowed set from **real example values** in the codebase,
    spec, or upstream docs, not intuition; grep representative inputs and assert each character/token passes (intuition
    rejects legal-but-uncommon chars like `:` in a versioned identifier).
- **Coverage check:** list paths before writing tests; confirm every documented success case, every documented failure
  case, and at least one edge case per input axis (lists, strings, numbers, optional fields). Any uncovered axis → add
  the path before writing any test.

## Stage 2: Choose test type per path

Take the first that works:

1. **Behavioral unit test** (default): contract observable through the public interface; replace collaborators with
   real-or-fake doubles at the boundary.
2. **Property-based test**: invariants hold across the input space (sort output sorted, encode/decode roundtrips,
   idempotent serializers); one replaces dozens of examples.
3. **Snapshot / golden test**: large structured output (HTML, generated SQL, AST), only if reviewers will actually
   inspect snapshot diffs.
4. **Integration test**: only when behavior depends on a real collaborator's semantics (DB query plan, HTTP/2 framing,
   OS scheduler, file-system races); use sparingly.
5. **Structural test**: **last resort only**, when behavior cannot be observed at all (e.g., a hook registered with a
   framework that exposes no observable side effect). Add a one-line comment naming the unavailable observation:
   `# structural: framework provides no hook to observe registration; refactor target.`

## Stage 3: Write the tests

Arrange (inputs + boundary state) → Act (call the public interface) → Assert (observable outputs / state changes /
emitted events).

- Never mock inside the unit's boundary; replace collaborators only at process boundaries (network, disk, clock).
- Never use mock-call-count as the primary assertion: assert emitted record shape, not logger call count.
- One test = one observable claim; no mega-tests.
- Never assert on private state: widen the public observation surface or skip the assertion.
- Match the project's test framework, layout, and naming; defer to `wk-format` for style.
- Framework patterns — consult when writing tests in these contexts:
  - [Bats / shell patterns](references/bats-patterns.md) — assertion propagation, tilde expansion, fake binary stubs,
    harness payload interpolation
  - [RSpec / Rails patterns](references/rspec-patterns.md) — message-expectation cardinality, stubbed-ENV leaks,
    shared-state restoration, ad-hoc probe rollback
  - [General patterns](references/general-test-patterns.md) — full-schema fixtures, boundary fake contracts, actionable
    agent fixtures, error string verification, gesture-gated extensions

## Stage 4: Mutation verification

Required for every new behavioral test (exempt: property-based — the shrinker mutates; snapshot — the diff verifies).
After each test or batch:

1. Mutate the implementation minimally: flip a conditional (`<` → `<=`), hardcode a return, remove a validation, swap
   two sub-call arguments, `+` → `-`, `&&` → `||`.
2. Run the intended example by exact description, not source line; confirm its name in runner output (a green nearby
   example is not evidence).
3. Verify the test fails.
4. Restore the implementation.

- A contract-breaking mutation that breaks no test → add the missing assertion before moving on.
- Shipping > ~5 new tests: batch 3-5 different mutations, run the suite, confirm each fails at least one test; a
  mutation failing nothing means a missing or structural test.

## Stage 5: Coverage as receipt

After tests pass and mutations verify, read coverage only to confirm Stage 1's map was honored:

- Uncovered branch → add the missed path's test, or remove/refactor the unreachable code.
- Already-covered branch → never add redundant tests to inflate the number.
- CI coverage gate → respect it; fix by finding the missing path, never by structural line-touching tests.

## Coordination

- `wk-workflow` Phase 3: this skill produces the plan first; Phase 3 runs lint, types, and the full suite with the same
  happy/sad/edge shape.
- `wk-format`: test files are code; formatting applies identically.
- `wk-commit`: tests ship in their own commit (preferred), or with the implementation in one commit using the `🧪` emoji
  when inseparable.
- `wk-pr-review` Phase 4: its playground mutation step applies the same check to someone else's tests, against this
  plan.

## Post-Completion

Invoke `wk-learn testing-skeleton`.
