---
class: principle
date: 2026-05-28
source:
  - ~/.claude/memory/feedback_runner_spec_nil_ci_env.md
severity: medium
---

- **Rule** — when a test stubs the process environment, explicitly set every env var the code under test reads (including ones the test does not want set) to `nil`/absent in the stub.
- **Why** — `.compact` (or equivalent) strips `nil` entries, so missing keys fall through to the real environment; CI runners inject `BUILDKITE_*`, `GITHUB_*`, `CI`, `RUNNER_*` that the local shell does not, producing local-pass / CI-fail with misleading "expected nil got URL/token" messages far from the root cause.
- **Where** — new "Nil-out consumed env vars in stubbed-ENV tests" subsection in Stage 3 of `wk-testing-skeleton` SKILL.md.
