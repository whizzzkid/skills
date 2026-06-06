---
skill: wk-pr
date: 2026-06-05
type: correction
severity: high
---

PR description behavioral claims must be derived from the implementation, not narrated from intent.

**What happened:** PR description described the severity behavior of a new check inaccurately — a critical qualifier ("project-wide") was omitted, making the blocker condition appear broader than the implementation actually enforces. The error was present from the first draft, not introduced by drift.

**Root cause:** The PR body was written as a narrative summary of intended behavior rather than derived by re-reading the artifact being described. Claims about thresholds, conditions, and severity ladders require quoting or directly cross-checking the source, not paraphrasing from memory.

**Suggested fix:** Before finalizing any PR body section that describes behavioral rules, conditions, or severity — re-read the relevant file and verify each claim against it verbatim. For checks/validators, quote the severity ladder directly from the file rather than summarizing it.
