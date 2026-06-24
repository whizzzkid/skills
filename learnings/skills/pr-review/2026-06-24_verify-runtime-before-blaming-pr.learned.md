---
skill: wk-pr-review
date: 2026-06-24
type: gap
severity: medium
---

When a local test suite fails during review, verify the interpreter version against the project's required runtime before attributing the failure to the PR.

**What happened:** Running the project's bats suite locally produced 8 failures, all sourcing a shared shell library at one line with `syntax error near unexpected token '('`. The PR under review only touched comments in that file, far from the failing line. The failures were caused by the host's default `bash 3.2` (macOS), while the library uses `bash 4+` syntax; CI runs a modern bash. Re-running under `bash 5` made all tests pass.

**Root cause:** The review flow ran tests with whatever interpreter was first on `PATH` without checking it matched the project's expected runtime. A pre-existing environment incompatibility looked like a PR-introduced regression and nearly became a false blocker.

**Suggested fix:** Before treating a local test failure as a PR finding: (1) check whether the failing line is in the PR's diff at all — a failure far from changed lines is a strong tell it's environmental; (2) confirm the interpreter/runtime version matches what the project pins (mise/.tool-versions/CI config); (3) re-run under the correct version (e.g. a `mise`/homebrew modern `bash`) before reporting. The adversarial-review runtime-matrix step already prescribes "run every interpreter the diff exercises, not whatever is first on PATH" — apply the same discipline to the pr-review test-run step.
