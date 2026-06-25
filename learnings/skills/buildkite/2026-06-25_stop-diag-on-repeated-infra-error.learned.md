---
skill: wk-buildkite
date: 2026-06-25
type: correction
severity: medium
---

When the same infra-level CI error repeats across multiple rebuilds, stop diagnosing and tell the user — do not list all jobs.

**What happened:** A CI step failed 3× across 3 rebuilds with an identical infra error (git mirror networking failure unrelated to code). The agent was about to list all build jobs as its next diagnostic step; the user interrupted with "stop."

**Root cause:** No rule prevents exhaustive job-listing when the failure pattern is already identified as infra-side. Three identical errors across independent rebuilds is a clear infra signal — further listing adds noise, not signal.

**Suggested fix:** After ≥2 consecutive rebuilds fail with the same error string on the same step, classify as infra and stop — report the pattern to the user and recommend waiting for the CI system to recover rather than listing or re-diagnosing.
