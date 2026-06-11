---
skill: wk-adversarial-review
date: 2026-06-10
type: correction
severity: medium
---

Verify the diff string passed to the adversarial subagent matches `git diff` output exactly.

**What happened:** When constructing the diff string for the subagent prompt, the agent accidentally duplicated two severity-guide lines. The subagent flagged the duplication as a blocker — but the actual committed file was correct. This generated a false blocker that consumed a fix cycle.

**Root cause:** The diff was written inline into the agent prompt rather than taken directly from `git diff "$BASE...HEAD"` output. Manual transcription introduced the duplication.

**Suggested fix:** Always pipe `git diff "$BASE...HEAD"` output directly into the subagent prompt rather than transcribing it manually. If inline embedding is necessary (length limits), verify the embedded snippet against the actual file with a quick grep for duplicated lines before dispatch.
