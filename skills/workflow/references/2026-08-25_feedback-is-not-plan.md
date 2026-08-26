---
class: principle
source: learnings/skills/workflow/2026-08-25_feedback-is-not-plan.md
---

# Raw feedback is not an implementation plan

A user-supplied artifact (Markdown file, review notes, feedback) is not an
approved plan unless it includes the structural minimum: implementation
sequence, scope/dependency decisions, acceptance criteria, verification steps,
and shipping boundaries.

A filename and imperative feedback were mistaken for decisions about scope,
dependency order, commit boundaries, verification, and PR strategy. Treat
such artifacts as requirements input for `wk-plan`, not as an approved plan
that bypasses planning.
