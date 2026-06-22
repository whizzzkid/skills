---
skill: wk-pr-resolve
date: 2026-06-20
type: correction
severity: medium
---

Step 2 branch sync was skipped — relying on Step 9 test-merge as a retroactive validator

**What happened:** The skill moved directly from Step 1 (identify PR) to Step 3
(fetch comments), skipping the prescribed Step 2 sync commands (fetch base, check
ahead/behind, merge or delegate to wk-pr-update). The Step 9 test-merge later
confirmed "Already up to date", which was used post-hoc to justify the skip.

**Root cause:** With only a single open finding and a branch that appeared current,
the Step 2 block felt redundant and was elided. The skill instructions require Step 2
unconditionally — "Already up to date" is a valid outcome of running it, not a
rationale for skipping it.

**Suggested fix:** Add explicit enforcement language to Step 2: "Run fetch + merge-base
check before triaging any comments, regardless of apparent branch state. The Step 9
test-merge is a conflict check, not a sync substitute. A skipped Step 2 is a protocol
violation even when Step 9 clears clean."
