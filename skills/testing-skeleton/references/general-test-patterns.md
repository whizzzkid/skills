# General Test Patterns

## Fixtures match the full expected schema

When the unit consumes a structured payload (JSON, API response, hash, dataclass), the fixture must include every field the schema requires — not just the subset the current test exercises.

- Read the schema from production code paths, an OpenAPI/JSON-Schema spec, or other passing tests in the suite. Use those as the minimum field set in every new fixture.
- Minimal stubs (only the fields the current assertion touches) create hidden coupling: when another code path on the same struct branches on a previously-unused field, every test using the minimal fixture starts asserting on undefined behavior or crashing on `fetch`/key-access of the missing field.
- Property-based / generated fixtures must constrain by the same schema; a randomized hash without required fields is no safer than a handwritten minimal one.

## Enforce external API contracts in boundary fakes

- Pair prerequisite configuration or permission assertions with an adapter test; prerequisites do not prove the call
  contract.
- Make boundary fakes reject unsupported argument counts and types, then reproduce the documented return and
  async-completion shape.
- Drive the adapter through its public interface and assert the observable result or error.
- Mutation-verify the test by breaking an argument or return shape; a surviving test does not protect the integration
  contract.

## Agent-consumed fixtures must be actionable

An end-to-end fixture for an agent-facing export or interchange format must
state a realistic problem and desired outcome. Validate that the downstream
consumer can act on the result; archive creation, field shape, and text
persistence prove transport only. See [semantic fixture
realism](semantic-fixture-realism.md).

## Verify the error string before coding a fallback that catches it

When writing a fallback that discriminates on a specific tool error message (`if stderr matches "X" then fall back`), run the failing command against a real-enough environment first to capture the exact wording.

- Error wording differs across tool versions and platforms; a guessed string makes the fallback either never fire or swallow unrelated failures.
- Corollary of the "probe capability, don't parse error text" rule in `wk-workstyle`: if you must match on error text, derive it from observation, not intuition.
- For git network errors, use `file://` URIs to activate the network code path in a local test instead of bare paths (which use the local protocol and emit different errors).

## Trigger gesture-gated extension permissions through the browser

Before an assertion depends on `activeTab`, trigger the extension's real browser
action or command through the browser protocol. Direct navigation to an
extension popup page does not grant `activeTab`; it tests only
permission-independent popup behavior.

- Assert the gated behavior after the gesture and include a negative case
  without it.
- Treat a timeout after direct popup navigation as a setup failure before
  changing the extension implementation.
- See [gesture-gated extension
  tests](gesture-gated-extension-tests.md).
