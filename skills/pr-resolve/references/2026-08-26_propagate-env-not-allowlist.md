---
class: one-off
source: learnings/skills/pr-resolve/2026-08-26_propagate-env-not-allowlist.md
---

# Buildkite propagate_environment makes per-step env documentary

When a Buildkite pipeline sets `propagate_environment: true` at the pipeline
level, per-step `env:` arrays are additive/documentary convention, not a
strict allowlist. A bot finding claiming a missing env var in the `env:`
array will prevent it from reaching the container is a false positive in
this configuration.

Check for `propagate_environment: true` before accepting such findings.
