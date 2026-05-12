---
skill: wk-self-review
date: 2026-05-12
type: gap
severity: high
---

Before approving a defensive guard on external input, trace the full execution path to verify the guarded value can actually reach that branch. Also verify that test fixtures match the real tool's output contract, not a hypothetical value.

**What happened:** PR #NNN added `head_branch == "null"` as a guard alongside `gh api --jq '.head.ref // empty'`. Self-review approved it as "defensive." Copilot caught in the next review cycle that with `// empty`, jq converts null → empty before Rust sees it — the guard was dead code. Worse, a companion bats test wrote the literal string `"null"` to the shim stdout, which doesn't match what real jq produces for null fields (empty string). The test was validating behavior that can't happen in production and was propping up the dead guard.

**Root cause:** Self-review evaluated the code at the line level without tracing the pipeline in front of it. The jq expression upstream already eliminated the problematic value; the guard was checking a case that can't be reached.

**Suggested fix:** For every defensive guard on external input, ask two questions before approving:

1. **Execution path:** Given every upstream transform (jq expressions, `trim()`, encoding conversions), can this exact value reach the guard? If an earlier stage already converts it (e.g., `// empty` converts null → `""`), the guard is dead code and creates false-positive risk for valid inputs that match the sentinel.

2. **Fixture realism:** Does the test fixture match what the real tool outputs for that case? If production uses `gh api --jq '.field // empty'`, a shim returning `"null"` simulates behavior that can't happen. The fixture should match the real output contract.

These two issues always co-occur: when a guard is written based on test-fixture reasoning rather than production-path reasoning, the fixture will be wrong for the same reason the guard is wrong. Audit them as a pair.
