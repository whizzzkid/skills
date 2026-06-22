---
class: principle
---

**Rule** — When a Jira key or URL appears in the session-opening prompt, run wk-jira Stage 0 + 1 + 2 (surface + assign + In Progress + sprint + comment) before wk-workflow Phase 1 planning begins. The development claim is a precondition for the work session, not a side-effect of it.

**Why** — wk-workflow's "any development task" trigger otherwise fires first and dominates the turn, skipping the claim entirely — the ticket never moves to In Progress, is never assigned, and gets no sprint at session start. The transition then only happens retroactively after the PR exists, when the user asks why the ticket never moved.

**Where** — Trigger ordering between wk-jira and wk-workflow. An opening-prompt key with development intent gates wk-workflow Phase 1 on the claim completing.
