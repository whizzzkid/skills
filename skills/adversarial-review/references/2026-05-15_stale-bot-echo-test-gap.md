---
class: one-off
---

- **Scenario:** Multi-cycle PR — a bot re-reviews after a prior cycle landed tests for helper `X` and `Y`; bot's file-level analysis lumps `X` (already tested in an earlier commit of the same PR) with `Y` (genuine gap) as "lacks tests".
- **Symptom:** Adversarial-review escalates the bot finding as a blocker for `X` even though a test for `X` already exists in `$BASE..HEAD`.
- **Fix:** For each symbol named in a multi-symbol "lacks tests" finding, run the per-symbol verification against the PR's own commit history before escalating:

  ```bash
  BASE=$(gh pr view --json baseRefName --jq .baseRefName)
  for sym in <symbol-list>; do
    if git log "$BASE..HEAD" -p -- '**/*_test.*' '**/*.spec.*' '**/spec/**' | grep -qE "\\b$sym\\b"; then
      echo "$sym: test landed in PR commit history — likely stale echo"
    else
      echo "$sym: genuine gap"
    fi
  done
  ```

  Escalate only the genuine-gap subset; reply to the bot noting the others as already addressed.
- **Why not promoted:** Adversarial-review's Step 3 subagent already hunts "no test for new function"; this case only fires when a bot's lumped finding meets a multi-cycle PR. Existing rules cover the common path; this is a narrow disambiguation recipe.
