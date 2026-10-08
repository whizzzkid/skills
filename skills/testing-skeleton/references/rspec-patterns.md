# RSpec / Rails Test Patterns

## Match message-expectation cardinality to the call's fan-out

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

## Nil-out consumed env vars in stubbed-ENV tests

When a test replaces the process environment (e.g., `stub_const("ENV", ENV.to_h.merge(...).compact)` in RSpec, `monkeypatch.setenv` / `delenv` in pytest, equivalent harness patterns elsewhere), explicitly set every env var the code under test reads — including the ones the test does NOT want set — to `nil` / absent in the stub.

- Grep the code under test for every `ENV[...]`, `ENV.fetch(...)`, `os.environ[...]`, `process.env.X` call. Each must appear in the stub with a chosen value or explicitly `nil`.
- `.compact` (or equivalent) strips `nil` entries from the stub. With `.compact`, "not in the hash" means "read from the real environment" — exactly the CI-leakage trap. Either keep the `nil` entries without compacting, or use the framework's `delete_env` API explicitly.
- Local pass + CI fail with messages like "expected nil, got URL" or "expected nil, got <token>" is the canonical signature of this leak — CI runners inject `BUILDKITE_*`, `GITHUB_*`, `CI`, `RUNNER_*`, and similar vars the local shell does not.

## Restore shared/global state a test mutates

A test that mutates process- or framework-level shared state (redraws a web framework's route table, monkeypatches a class method, swaps a global registry/singleton) leaks that mutation into every test that runs after it unless it explicitly restores the original in an `after`/teardown hook.

- The failure is order-dependent: the mutating test passes alone, and the polluted tests fail only when run after it — the signature is unrelated tests failing after a suite reorder or a new nearby test.
- Standard test-runner isolation (transactional DB rollback, per-example object doubles) does not cover state a test explicitly replaces at the module/class/framework level — pair every such mutation with an explicit restore.
- Rails example: a controller spec calling `routes.draw` to register a probe route must restore the real table afterward (`after { Rails.application.reload_routes! }`) — otherwise later request specs 404 against the stripped table.

## Roll back or re-prepare after an ad-hoc probe

An interactive verification script run through the framework's runner against the test database is a state mutation with no safety net: runners **commit by default**, unlike the spec suite, which wraps each example in a rolled-back transaction.

- Wrap every probe in an explicit always-rollback transaction, or re-prepare the test database immediately after the probe and before the next suite run.
- Treat an unexplained failure in a spec the current change does not touch as self-inflicted state pollution **first**, not a regression — leftover rows are indistinguishable from a fixture the suite never created, so the phantom failures read as real ones.
- The rule covers any out-of-suite write path (console session, seed script, one-off migration), not only a runner invocation.
