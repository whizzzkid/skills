---
skill: wk-renovate
date: 2026-11-19
type: gap
severity: high
verified-against-source: yes
---

A changelog default-behavior change was audited only at the call site the agent touched; every other caller regressed.

**What happened:** A pre-1.0 telemetry exporter bump turned on retries by default. The agent disabled retries for the
one crate it was editing. A fresh adversarial reviewer then found the same builder in three other CLI binaries: a
synchronous exporter now blocked about 0.9s per span, and a batch flush blocked at exit. With no collector listening,
each command got 1-2s slower. The same release also turned an invalid endpoint env var into a build error, which an
`.expect` made into a startup panic.

**Root cause:** The Step 4 major-version audit asks for "the app's use of changed APIs", but nothing forces a
workspace-wide grep of every construction site, or a runtime check of the failure-mode default (endpoint unreachable
or invalid). Green tests are expected, because tests never run with an unreachable collector.

**Suggested fix:** In Step 4, for each default-behavior change, grep every call site of the changed builder or type
across the workspace and list them in the audit section. For network-client defaults (retries, timeouts, endpoint
parsing), time the CLI on base vs head against an unreachable endpoint and with an invalid endpoint value.

Also observed:
- A patch release can raise the MSRV, which explains a standalone Dependabot PR that fails CI. Bump the toolchain pin
  in the combined PR and check repo history for precedent.
- `cargo test -p <crate>` does not enable that crate's feature-gated test utilities for its own integration tests.
  Workspace-wide `cargo test` hides this through feature unification. Run the crate-scoped command for new
  integration tests.
