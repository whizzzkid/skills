---
skill: wk-adversarial-review
date: 2026-05-22
type: gap
severity: medium
---

Catch bug fixes that ship without a regression test asserting the fixed behavior.

**Class:** Bugfix-without-regression-test.

**Mechanism:** A PR includes a one-line defensive fix (a `&.to_s`, a nil-check, a type coercion) without a paired test that would have caught the original bug. The fix is correct, but a future refactor can silently revert it because no spec asserts the post-fix behavior. Reviewer bots flag this as a test-coverage gap.

**Detection sketch:** In Step 2.15 (workstyle pass), add a check for "fix without regression test." For every commit whose subject matches `^fix(`, `^bug:`, or `^bugfix:`, enumerate the changed source files. For each changed source file, verify the same commit adds at least one test function in the parallel spec/test file:

```bash
for sha in $(git log --format=%H "$BASE..HEAD" --grep='^fix\|^bugfix'); do
  src_changed=$(git show --name-only --pretty=format: "$sha" | grep -vE '^(spec|test|tests)/')
  test_changed=$(git show --name-only --pretty=format: "$sha" | grep -E '^(spec|test|tests)/')
  if [ -n "$src_changed" ] && [ -z "$test_changed" ]; then
    echo "BLOCKER: $sha changes source without test"
  fi
done
```

Suggestion-level when the fix is one line and the existing spec has parallel structure; blocker when the fix introduces a new branch.

**Confidence:** high — mechanical commit-shape grep; no LLM reasoning required.
