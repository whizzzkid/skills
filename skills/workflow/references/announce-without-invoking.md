---
class: principle
skill: wk-workflow
date: 2026-06-18
---

**Rule:** A skill is invoked only when the `Skill` tool call appears in the same
response as its announcement. Text like "now running the adversarial review gate"
without a same-turn `Skill(...)` call is a protocol violation. If the agent
detects it announced a skill without invoking it, it must invoke it before any
other action.

**Why:** The agent narrated "running adversarial review now" and moved on without
the call; the review was silently skipped and the user had to ask "still
running?" before the omission was caught. Narration is not action.

**Where:** Autonomy Rules — skill-invocation HARD RULE.
