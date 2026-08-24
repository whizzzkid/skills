---
skill: wk-workflow
date: 2026-08-24
type: correction
severity: medium
verified-against-source: n/a
---

Never chain shell commands with && in Bash tool calls

**What happened:** Agent routinely chained multiple shell commands with `&&` in
a single Bash tool invocation. User explicitly corrected: "don't run compound
commands."

**Root cause:** No instruction in the workflow skill prohibiting compound shell
commands. The agent defaulted to chaining for efficiency without considering
that compound commands are harder to review, debug, and permission-gate.

**Suggested fix:** Add a rule to wk-workflow: "Issue each shell command as a
separate Bash tool call. Never chain commands with `&&`, `||`, or `;` in a
single invocation — each command must be independently reviewable and
permission-gated."
