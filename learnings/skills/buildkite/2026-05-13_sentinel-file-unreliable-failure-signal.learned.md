---
skill: wk-buildkite
date: 2026-05-13
type: correction
severity: high
---

Never use a side-effect file written by an upstream step as a failure-detection signal.

**What happened:** To detect `claude_sandbox` failure in `post_review`, I wrote a sentinel file (`findings.json` with `{"stalled": true}`) in the sandbox step's cleanup trap. The downstream step would then check for this sentinel. The user rejected it: if the sandbox crashes before reaching the cleanup trap, no sentinel is written, and the downstream step has no signal at all — the exact failure case we were trying to handle.

**Root cause:** Used a side-effect artifact as a proxy for step status, coupling the signal to a code path that may not execute in the failure scenario.

**Suggested fix:** Always use the CI platform's native step-outcome API (`buildkite-agent step get "outcome" --step "<key>"`) to read upstream step status. This is written by the platform, not the step's own code, and is available regardless of how the step terminated.
