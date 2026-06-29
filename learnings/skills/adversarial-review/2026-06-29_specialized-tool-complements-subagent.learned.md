---
skill: wk-adversarial-review
date: 2026-06-29
type: pattern
severity: medium
---

specialized second-opinion tool and adversarial subagent catch different issue classes — both are necessary

**What happened:** The adversarial LLM subagent cleared the diff (0 blockers, 0 suggestions). The specialized local review binary then caught a real test reliability bug: an `exec.Command` helper silently passed when the command failed with a non-`ExitError` and `wantExitCode != 0`. The subagent had reviewed the same helper and found no issue.

**Root cause:** LLM subagents reason about logic and correctness at a semantic level but can miss low-level Go error-type distinctions (ExitError vs other exec errors). The specialized tool's checks run prompts targeting specific concern classes (error-handling, type-precision, test-coverage) that are better calibrated for this kind of gap.

**Suggested fix:** When folding the specialized tool's results, treat its specialized checks (error-handling, test-coverage) as authoritative for their domains even when the general adversarial subagent cleared the same code. The two tools are complementary, not redundant.
