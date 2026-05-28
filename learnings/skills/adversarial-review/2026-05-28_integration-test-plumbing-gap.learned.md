---
skill: wk-adversarial-review
date: 2026-05-28
type: gap
severity: medium
---

One-line pass-through changes lack an integration test verifying end-to-end wiring.

**What happened:** A script was modified to pass a new parameter from a JSON artifact to a downstream function. The unit tests covered both the source (JSON serialization) and the sink (function behavior with the param), but no test verified the wire — that the script actually reads the key from JSON and forwards it correctly. A bot review surfaced the gap.

**Root cause:** The adversarial review's test-quality sweep (Step 2.15) checks for missing sad-path tests and new-function coverage, but does not specifically audit pass-through wiring in scripts/entrypoints where the "test" is spread across two separate unit-test files with no integration gluing them.

**Suggested fix:** When the diff changes a script/entrypoint to add a new `key -> parameter` forwarding pattern (e.g., `findings["x"]` → `run(param: findings["x"])`), add a check: is there an integration or end-to-end test that constructs a fixture JSON with the key set and asserts the downstream behavior fires? Unit tests on each end are not sufficient when the wire itself (the `findings["key"]` lookup) is the new code.
