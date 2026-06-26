---
skill: wk-adversarial-review
date: 2026-06-26
type: gap
severity: medium
---

When adding a new data field to a context payload, update adjacent skill prompts that consume that payload in the same implementation step — not as a post-review fix.

**What happened:** A new `commits` field was added to the PR context bundle sent to a reviewer skill. The reviewer skill's instruction block was not updated to reference the new field during implementation. Adversarial review surfaced the gap: the field existed in the payload but the reviewer had no instruction to use it, making the fix invisible unless the reviewer happened to notice the field.

**Root cause:** The implementation checklist covered code (producer) and tests but did not include a step to update consumer-side skill prompts when the context schema changes. The connection between "add a field to the context" and "update the skill that reads the context" is non-obvious and not currently in the implementation checklist.

**Suggested fix:** Add a sweep check to the mechanical catalog: when the diff adds a field to a structured context payload that feeds an LLM skill/prompt, grep for the skill file(s) that consume that payload and verify the field is referenced. If absent, flag as a blocker — an undocumented field is effectively invisible to the model consuming the context.
