---
class: principle
---

# Diff the plan at every batch boundary; continue without asking

**Rule**

- After each batch of a multi-item plan, list done vs remaining against the original plan.
- Originating directive covers the next item ("fix all") → start it without asking.
- A sub-agent's "targets met" report is not plan completion.
- Any item not being done → defer it explicitly, with a reason, in the same message.

**Why**

- A multi-item plan ran in batches; after each the agent summarized and asked "go ahead?", and several plan items were
  never revisited until the user asked whether everything was done.
- The Continuity final gate ("every step finished or explicitly deferred") existed before the incident but ran only at
  the end, so per-batch drift went unchecked; the Autonomy rule against per-step permission was also already present.

**Escalation**

- Re-violation of the Continuity rule → one rung: baseline → `**Important:**`, plus the new batch-boundary trigger.

**Where**

`skills/workflow/SKILL.md` → Autonomy Rules → Continuity.
