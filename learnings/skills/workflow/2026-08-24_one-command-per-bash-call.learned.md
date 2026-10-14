---
skill: wk-workflow
date: 2026-08-24
type: correction
severity: medium
verified-against-source: n/a
---

Each Bash tool call should contain one command, not compound chains

**What happened:** Compound shell commands chained with `&&` were used repeatedly in Bash tool calls until the user corrected the pattern. The user expects one discrete command per Bash invocation.

**Root cause:** No explicit rule in the skill requiring single-command Bash calls. The agent defaulted to chaining for efficiency, but this makes it harder for the user to review, approve, and debug each step.

**Suggested fix:** Add a rule: each Bash tool call should execute one command. Do not chain commands with `&&`, `||`, or `;`. If multiple commands are independent, use parallel tool calls. If sequential, use separate Bash calls.
