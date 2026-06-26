---
skill: wk-pr-resolve
date: 2026-06-26
type: correction
severity: high
---

Step 2 behind-main detection must immediately trigger `git merge` — detecting the count without acting is a violation.

**What happened:** Step 2 computed `$BEHIND=3` (branch was 3 commits behind the base), logged the number, and moved straight to triaging review comments. No merge was run. The branch stayed on a stale base until the user noticed and asked why the skill hadn't synced it.

**Root cause:** The skill's Step 2 check has two parts — detect, then act — but only the detection was treated as "done." The action (`git merge origin/$BASE_BRANCH`) was implied by the prose but never executed. The agent treated the sync check as informational rather than imperative.

**Suggested fix:** Make the instruction atomic: "If `$BEHIND > 0` and `$BEHIND <= 5`, run `git merge origin/$BASE_BRANCH --no-edit` before reading any comment. The check and the merge are one unit — never report `$BEHIND` and continue without merging."
