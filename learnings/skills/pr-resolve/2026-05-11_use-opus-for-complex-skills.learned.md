---
skill: wk-pr-resolve
date: 2026-05-11
type: gap
severity: medium
---

Use Opus for complex multi-step skills like pr-resolve.

**What happened:** wk-pr-resolve was run on Sonnet 4.6 (1M context) instead
of Opus. The skill involves deep code reasoning, design signal detection,
multi-surface comment triage, fix generation, and loop-back logic — all of
which benefit from Opus-level judgment quality.

**Root cause:** No instruction in the skill or global config specifies which
model to use. The session defaulted to whatever the user had active (Sonnet).

**Suggested fix:** Add a model recommendation note near the top of wk-pr-resolve:
"This skill benefits from Opus-level reasoning. If available, switch to Opus
before running (`/model opus`)." Same applies to wk-pr-review and any other
skill where multi-step judgment is the core value.
