---
skill: wk-pr-resolve
date: 2026-06-23
type: gap
severity: medium
---

When fixing a value/message reporting defect, grep the whole file for sibling uses of the same pattern before committing.

**What happened:** A bot review flagged a timeout error message using the actual elapsed time instead of the configured constant. The fix was applied to the flagged line. A sibling function introduced by the same refactor carried the identical defect on a different line — caught only by the adversarial subagent after commit, requiring a second fix commit.

**Root cause:** Step 6's issue-class scan instructs grepping the PR diff for sibling paths, but does not explicitly call out the case where the sibling is a newly-extracted helper in the same file — it was added by this PR's commits, so the diff scan found it, but the fix pass only targeted the originally-flagged location.

**Suggested fix:** Add an explicit instruction to Step 6: after fixing a value/message/constant reporting defect, grep the entire changed file (not just the diff) for all occurrences of the same pattern (e.g., `grep "timed out after %v" <file>`) and treat each match as a candidate for the same fix unless a structural reason justifies divergence.
