---
date: 2026-05-13
slug: native-step-outcome
---

- **Rule:** Read upstream step status from `buildkite-agent step get "outcome" --step "<key>"`; reject sentinel files and artifact-existence as proxies.
- **Why:** Side-effect signals depend on the upstream step's code path executing. When the step crashes before its cleanup, no signal is written — exactly the failure the downstream detection exists for. The agent-written outcome survives any termination mode.
- **Where:** `Reading upstream step status from a downstream step` section in `wk-buildkite` SKILL.md.
