---
skill: wk-workflow
date: 2026-05-13
type: gap
severity: medium
---

Prompt the user for a Jira ticket before beginning code exploration, not after.

**What happened:** Agent began reading code files immediately after the task was described. User interrupted mid-exploration to provide a Jira ticket URL and request the Jira workflow be followed.

**Root cause:** wk-workflow Phase 1 (Plan) does not include a step to check whether a Jira ticket exists before starting investigation. The ticket context (acceptance criteria, linked spec) is most useful at plan time, not after exploration is underway.

**Suggested fix:** Add a Phase 1 pre-flight question: "Is there a Jira ticket for this work?" If yes, invoke wk-jira Stage 0+1+2 before spawning exploration agents. This keeps ticket sync atomic with work start and surfaces acceptance criteria before the plan is written.
