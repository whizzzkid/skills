---
class: one-off
skill: wk-pr-merge
date: 2026-05-29
---

# Announce when executing a stubbed (RED-phase) skill

- **Scenario:** A skill is invoked whose step bodies are stub markers
  (`<!-- RED phase not yet run -->`, `<!-- DESIGN NOTES -->`) with no executable
  instructions.
- **Symptom:** The agent silently executes the steps from context/intent
  without disclosing the skill is unimplemented; the user interrupts to ask
  what is happening.
- **Fix:** At invocation, check whether step bodies are populated. If stub
  markers appear in more than one step, announce before proceeding: "This skill
  is in RED phase (steps not implemented) — I'll work through its intent from
  the headings; flag me if my interpretation diverges."
- **Why not promoted:** Now-rare configuration — `wk-skill` was changed this
  session to write full skill bodies by default, so stubbed skills should no
  longer be produced; and the tagged skill (wk-pr-merge) is itself now fully
  implemented. No clean cross-skill home for a general "announce RED phase"
  rule, so kept as a reference rather than folded into a SKILL.md.
