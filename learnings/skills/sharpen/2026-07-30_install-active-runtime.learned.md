---
skill: wk-sharpen
date: 2026-07-30
type: correction
severity: high
verified-against-source: yes
---

Install and verify the updated skill for the active agent runtime.

**What happened:** The repository already required a loop cycle to drain the
whole queue, but the active runtime still loaded an older one-item prompt after
the required installer refreshed a different agent target.

**Root cause:** The terminal install gate hard-codes one agent target and accepts
a generic success marker without comparing the active runtime's installed skill
bytes to the repository source.

**Suggested fix:** Install for the active agent target, then byte-compare its
`SKILL.md` and changed references to the repository before declaring the gate
complete.
