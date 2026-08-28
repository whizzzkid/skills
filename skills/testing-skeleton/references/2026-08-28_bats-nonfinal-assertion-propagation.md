---
class: principle
date: 2026-08-28
source:
  - learnings/skills/bats/2026-08-28_nonfinal-double-bracket.md
severity: high
---

Non-final `[[ ... ]]` assertions in a Bats test can fail without failing the test.

**What happened:** Mutation testing broke an early `[[ ... ]]` assertion, but the test still passed because later commands succeeded and set the exit status to 0.

**Root cause:** Bats uses the test function's exit status as the verdict. A failing `[[ ... ]]` sets a non-zero status, but subsequent commands (including passing assertions) overwrite it. Only the final command's status propagates.

**Principle:** Append `|| return 1` to every non-final `[[ ... ]]` assertion in a Bats test so failure propagates immediately.

```bash
# WRONG — first assertion failure is masked by second
[[ "$output" == *"expected"* ]]
[[ "$status" -eq 0 ]]

# CORRECT — early failure aborts the test
[[ "$output" == *"expected"* ]] || return 1
[[ "$status" -eq 0 ]]
```

**Why not `set -e`:** Bats runs each `@test` as a function; `set -e` behavior inside functions is inconsistent across bash versions and can mask other failure modes.
