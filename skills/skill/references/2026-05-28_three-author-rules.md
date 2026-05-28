---
class: principle
date: 2026-05-28
source:
  - ~/.claude/memory/feedback_skills_path.md
  - ~/.claude/memory/feedback_skill_invocation.md
  - ~/.claude/memory/feedback_skill_subcommand_state_fallback.md
  - ~/.claude/memory/feedback_skill_allowed_tools_discipline.md
severity: medium
---

- **Rule 1 — skills live in `$WK_SKILLS_HOME`, never `~/.claude/skills/`** (read-only path managed by install sync).
- **Rule 2 — model-invocation:** use `model-invocable: true` to opt in; `disable-model-invocation: false` is a no-op and reads as dead config.
- **Rule 3 — sub-command state fallback:** every sub-command that reads session state must pick a default and emit a one-line confirmation naming the resolved state.
- **Rule 4 — `allowed-tools` two-way sync:** every tool call in the body must appear in `allowed-tools`; every `allowed-tools` entry must be exercised by a body step.
- **Why** — silent failures and dead config rot a skill faster than missing features; the four rules are pre-flight checks the skill author can run mechanically.
- **Where** — new HARD RULE blocks in `wk-skill` SKILL.md Step 6 (rules 1–3) and Step 8 (rule 4).
