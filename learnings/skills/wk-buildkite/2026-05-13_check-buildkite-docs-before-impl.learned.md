---
skill: wk-buildkite
date: 2026-05-13
type: correction
severity: high
---

Always check Buildkite agent CLI docs before implementing step-status detection.

**What happened:** Implemented artifact-existence as a proxy for upstream step outcome (`buildkite-agent artifact search`). The correct, first-class API is `buildkite-agent step get "outcome" --step "<step-key>"` which returns "passed"/"failed"/"timed_out" directly — no file coupling needed.

**Root cause:** Did not search Buildkite agent CLI reference before designing the detection approach.

**Suggested fix:** When a task involves detecting CI step state in a downstream step, grep for `buildkite-agent step` in the codebase first, then check Buildkite docs for `buildkite-agent step get` before designing any workaround.
