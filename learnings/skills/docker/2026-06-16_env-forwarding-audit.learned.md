---
skill: wk-docker
date: 2026-06-16
type: gap
severity: high
---

Audit all env var reads against the container forwarding list before treating a docker-compose config as complete.

**What happened:** A pipeline step that runs a Ruby script inside Docker was missing four env vars from the docker_compose plugin `env:` array. The vars were available on the CI agent host but never reached the container. The runtime script logged "feature not enabled" even though the secret was correctly set at the pipeline level.

**Root cause:** Docker-compose (and Buildkite's docker_compose plugin) only forward env vars that are explicitly listed in the `env:` array. Agent-level vars — including CI builtins like `BUILDKITE_COMMIT` and user-defined secrets — are silently absent inside the container unless declared. Sibling pipeline templates had already forwarded some of the vars, but the newer template was written without auditing the full runtime read set.

**Suggested fix:** Add a mandatory env-forwarding audit step to `wk-docker`:
1. Grep every script and library invoked at container runtime for `ENV[`, `ENV.fetch`, `os.environ`, `process.env`, `$VAR`, etc.
2. Collect the full set of env var names read.
3. Diff against the `environment:` / `env:` list in the compose file or plugin config.
4. Flag any read that has no corresponding forwarding entry.
5. Cross-check sibling templates or compose files that serve similar roles — inconsistency between siblings is a strong signal of a missing entry.
Also note: never use a host-side SHA or build identifier (e.g. the CI runner's own commit SHA) as a proxy for a target-artifact SHA inside the container — they are different values and will fail downstream comparisons.
