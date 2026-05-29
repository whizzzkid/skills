---
skill: wk-workflow
date: 2026-05-27
type: correction
severity: high
---

Agent did not invoke wk-pr after implementation completed; user had to explicitly ask "why did you not create a PR from this?"

**What happened:** After completing all implementation commits, the agent stopped without proceeding to Phase 4 (adversarial review) and Phase 5 (PR creation via wk-pr). The workflow explicitly mandates these phases with no opt-out.

**Root cause:** After a multi-turn implementation session, the agent treated "commits landed cleanly" as session completion. wk-workflow Phase 5 is mandatory and requires no user prompt — the agent must continue autonomously from Phase 2 → 3 → 3.5 → 4 → 5 without stopping.

**Suggested fix:** After the final commit of a development task, never return control to the user before completing: (1) test suite run, (2) refactor scan, (3) wk-adversarial-review, (4) wk-pr. The only valid stop points before wk-pr are a blocked adversarial verdict or CI failure after 3 attempts. "Implementation is done" is not a stop point — it is the entry to the review and PR phase.
