---
class: principle
---

# One command per Bash call — re-violation escalation

**Rule** — Each Bash tool call should execute one command. Do not chain with `&&`,
`||`, or `;`. Use parallel tool calls for independent commands.

**Why** — Compound chains prevent per-command approval, make debugging harder, and
are blocked by auto-mode classifiers that cannot decompose them. Re-violated despite
existing baseline rule; escalated from baseline to `**Important:**`.

**Where** — `SKILL.md` → Phase 2 → Code Standards → *Shell simplicity*.
Escalation: baseline → `**Important:**` (rung 1 → 2).
