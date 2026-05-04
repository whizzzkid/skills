---
skill: wk:buildkite
date: 2026-05-04
type: gap
severity: medium
---

Use `buildkite-agent build cancel` to cancel the current build instead of calling the REST API.

**What happened:** Used `curl -X PUT .../builds/{n}/cancel` with BUILDKITE_API_TOKEN to cancel the current build, which requires a token and a separate API call.

**Root cause:** Didn't know the agent CLI exposes a `build cancel` subcommand that cancels the current build from within a running step — no token or API call needed.

**Suggested fix:** When a pipeline step needs to cancel its own build, use `buildkite-agent build cancel` (documented at https://buildkite.com/docs/pipelines/configure/canceling-builds). Reserve the REST API cancel endpoint for cancelling *other* builds from outside the running agent.
