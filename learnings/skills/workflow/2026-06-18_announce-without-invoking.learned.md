---
skill: wk-workflow
date: 2026-06-18
type: correction
severity: high
---

Announcing a skill invocation in text without actually calling the Skill tool creates a silent gap.

**What happened:** The agent wrote "Now running the adversarial review gate before pushing" in its text output but did not invoke the adversarial-review skill in that same turn. The review was silently skipped. The user had to ask "still running?" before the omission was caught and corrected.

**Root cause:** No rule enforces that a skill announcement and its Skill tool call must occur in the same response turn. The agent produced the intent text and moved on, treating narration as action.

**Suggested fix:** Add a HARD RULE: a skill invocation is only valid when the `Skill` tool call appears in the same response as the announcement. Text that says "I will now run X" without a same-turn `Skill(X)` call is a protocol violation. If the agent detects it has announced a skill without invoking it, it must invoke it before any other action.
