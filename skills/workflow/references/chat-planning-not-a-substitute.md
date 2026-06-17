---
class: principle
---

# A chat planning discussion does not substitute for invoking the workflow

**Rule**

- Even when the plan is clear from conversation, invoke `wk-workflow` before the
  first Edit/Write/Bash. The invocation gates that first write call.
- Treat "I already planned, the invocation is redundant" as a forbidden
  rationalization.

**Why**

- After a planning exchange, the agent announced "starting implementation" and
  began editing files without invoking the skill; the user interrupted.
- The skill invocation surfaces branch hygiene, guardrails, and pre-flight steps a
  free-form chat plan does not cover — planning content is not those gates.

**Where**

- `skills/workflow/SKILL.md` Mandatory Activation.
