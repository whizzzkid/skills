---
class: one-off
date: 2026-05-28
source: ~/.claude/memory/feedback_awk_duplicate_case_scoping.md
severity: low
---

- **Scenario:** Bats/grep test for a shell script containing multiple `case` statements with identical branch labels (e.g., `failed)` appears in both an emoji-mapping case and a PR-comment case).
- **Symptom:** Single-stage `awk '/failed\)/,/;;/'` matches the first occurrence — wrong case block — and the test silently asserts against the wrong region.
- **Fix:** Two-stage awk — outer scopes to the correct block via a unique anchor, inner scopes to the branch:

  ```bash
  awk '/Unique anchor comment/,/esac/' "$SCRIPT" \
      | awk '/failed\)/,/;;/' | grep -q 'THING'
  ```

  Check for duplicate branch labels first when writing any bats/grep test against a shell script with `case` statements.
- **Why not promoted:** Narrow bash-scripting recipe with verbatim awk commands; does not generalize cleanly to most agent runs and the principle ("scope range patterns to a unique anchor") is too thin without the bash specifics to be useful.
