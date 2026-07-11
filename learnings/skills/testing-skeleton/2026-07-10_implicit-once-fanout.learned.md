---
skill: wk-testing-skeleton
date: 2026-07-10
type: gap
severity: medium
---

An `expect(...).to receive(:method)` assertion carries an implicit `.once`, which false-fails when the method under test invokes that collaborator once per iterated input.

**What happened:** A spec asserted a shared sink (error tracker) was notified when a config lookup raised. The method reads two keys and each raise triggered its own notify, so the implicit-`.once` expectation failed with "expected 1 time, received 2 times" even though the behavior was correct.

**Root cause:** The default cardinality of a message expectation is exactly once. When the code fans the call out over a collection (per key, per record, per field), the real call count is data-dependent, not one.

**Suggested fix:** When asserting on a collaborator the method under test can call more than once — anything invoked inside a loop or once per input — use `.at_least(:once)` or an explicit count matched to the fan-out, never the bare `to receive` whose implicit `.once` couples the test to a single-input assumption.
