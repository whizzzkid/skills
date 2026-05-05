---
skill: wk-pr-resolve
date: 2026-05-05
type: correction
severity: medium
---

Presented a Step 5 consultation prompt for a comment whose skip rationale was "no valid reason" — should have been auto-applied.

**What happened:** Comments 2 and 3 had "Why this could be skipped: No valid reason." The skill still presented per-comment prompts asking `(a)/(e)/(d)/(s)`. User had to answer `a` and then correct this behavior.

**Root cause:** The `obvious-fix` classification rule exists in the skill (the skip-rationale check) but was not applied during Step 4. The agent tagged both as `judgment-required` based on the change shape (new test cases) rather than the skip rationale text.

**Suggested fix:** In Step 4, after drafting "Why this could be skipped", immediately check: does the text contain "no valid reason", "no good reason", or is effectively empty? If so, set tag to `obvious-fix` unconditionally — regardless of whether the change looks like a design decision, test addition, or refactor. The rule is about the skip rationale, not the change shape. In Step 5, include obvious-fix items in the bulk-apply preview rather than per-comment prompts unless the user has explicitly opted out of bulk apply.
