---
class: principle
---

**Rule:** When a diff adds a field to a structured context/payload consumed by
an LLM skill or prompt, grep the consumer skill/prompt file(s) for a reference
to the new field; flag an unreferenced field as a blocker.

**Why:** A field present in the payload but unreferenced in the consumer's
instructions is invisible to the model — the producer-side change has no effect.
The producer→consumer-prompt link is non-obvious and is missed by code-and-test
checklists that stop at the producer.

**Where:** Sweep 2.57 in `references/sweep-catalog-extended.md`; ID added to the
inline pointer list in `SKILL.md` Step 2.
