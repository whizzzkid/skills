---
skill: wk:workflow
date: 2026-04-24
type: gap
severity: high
---

Interruptions during a workflow run cause earlier plan steps to be silently dropped.

**What happened:** Mid-execution of the wk:workflow plan (implement → commit
→ test → review → PR → CI loop → self-review → docs audit → retro), the
user interrupted four times with new sub-tasks. I executed each sub-task
but never returned to the original plan's tail — CI loop, self-review,
docs audit, and retro were skipped. The user had to explicitly ask "did
you complete all the steps in the plan?"

**Root cause:** The skill does not prescribe a re-anchoring step after
an interruption. The natural flow is "user interrupts → execute new ask
→ continue with whatever was last on screen," and "whatever was last on
screen" is the new ask, not the original plan. There is also no
checkpoint that says "before responding 'done', re-read the plan and
confirm every step is finished or removed."

**Suggested fix:** Add an explicit "On interruption" subsection to
wk:workflow:

> When the user interrupts mid-plan, before executing the new ask:
> (1) update the active TodoWrite list — insert the new task at the
> appropriate position and verify all unfinished prior items are still
> listed, (2) re-state the new top of the plan briefly, (3) execute.
> Before declaring completion, re-read the full plan and confirm every
> step is either completed or explicitly deferred by the user.

Also add a final-gate in the post-completion checklist: "Confirmed
every numbered step is done — not 'most' or 'the important ones'."
