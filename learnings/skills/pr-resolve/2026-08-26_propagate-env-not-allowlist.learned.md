---
skill: wk-pr-resolve
date: 2026-08-26
type: surprise
severity: medium
verified-against-source: yes
---

Buildkite docker_compose per-step env: arrays are documentary, not restrictive

**What happened:** Bot findings claimed a missing env var (`REVIEW_HEAD_SHA`) in a
pipeline template's `env:` array would prevent the var from reaching the container.
Investigation found that the pipeline-level `propagate_environment: true` already
forwards all host env vars — a sibling template's comment explicitly states
"omitting from `env:` is documentation, not restriction." The per-step `env:` list
is additive/documentary convention in this codebase, not a strict allowlist.

**Root cause:** The bot's static analysis treated per-step `env:` as a strict
allowlist (reasonable default assumption) without checking the pipeline-level
`propagate_environment: true` setting that makes it redundant. The authoritative
source was a comment in `guardrail.rb` (a sibling template) that documents the
interaction explicitly.

**Suggested fix:** When triaging bot findings about missing env vars in Buildkite
pipeline templates, check for `propagate_environment: true` at the pipeline level
before accepting the finding — it changes `env:` from a gate to documentation.
