---
skill: wk-adversarial-review
date: 2026-06-26
type: gap
severity: medium
---

The local review binary must be an explicit named step in the pre-push gate, not only a memory entry.

**What happened:** The pre-push adversarial gate ran without invoking the local review binary. The binary was referenced in agent memory ("run before every push") but not in the skill's procedure, so it was skipped under session pressure. Multiple bot findings landed post-push that the binary would have caught locally.

**Root cause:** Memory entries are loaded per-session but compete with context pressure; skill procedure steps are always executed. A check that belongs in the pre-push gate must appear as a numbered step in the skill body, not as an ambient memory fact.

**Suggested fix:** Add an explicit numbered step to the adversarial-review pre-push gate: "Run the repo's local automated-review/static-analysis tool; read its findings output; fix any blockers/majors before committing." Gate the push on zero blockers/majors from that run.
