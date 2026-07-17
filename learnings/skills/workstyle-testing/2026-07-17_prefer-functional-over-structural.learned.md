---
skill: wk-workstyle-testing
date: 2026-07-17
type: correction
severity: high
---

Prefer functional tests that drive the real call path over structural tests that assert on config/data shape.

**What happened:** Asked to validate that a config-provided credential keyset makes an authenticated API call succeed, the first test parsed the config file and asserted on its YAML structure (a default value equals `[]`, no environment statically shadows the secrets-manager value). The user rejected it as a "structure test" and asked for a functional test that makes a real authenticated request using the actual test-env value (no config stub — `and_call_original`) and asserts a 200, plus a negative case asserting 401 for an absent token.

**Root cause:** A structural assertion on a config file's shape proves the file *looks* right, not that the feature *works*. It passes even when the real parse/lookup/compare path is broken (wrong lookup key, type mismatch, comparison bug, unregistered key). It tests the fixture, not the behavior.

**Suggested fix:** When validating that config/data makes a feature work, exercise the feature end-to-end through its real entry point (HTTP request, public method) against the real value — do not assert on the config file's literal structure. Reserve structural/shape assertions for genuine schema-contract tests, never as a proxy for "the feature works."
