---
skill: wk-pr-merge
date: 2026-05-29
type: gap
severity: medium
---

When a skill is in RED phase (stub bodies, no implementation), announce this upfront before executing manually.

**What happened:** The skill was invoked with empty step bodies marked `<!-- RED phase not yet run -->`. The agent silently proceeded to execute the steps manually without explaining the skill was unimplemented, causing the user to interrupt and ask "what does red phase mean?"

**Root cause:** The skill file exists with interface/heading structure but no executable instructions. The agent ran the steps from context rather than skill guidance, without disclosing the discrepancy.

**Suggested fix:** At the start of every skill invocation, check whether step bodies are populated or stubbed. If stub markers (`<!-- RED phase`, `<!-- DESIGN NOTES`) are present in more than one step, announce before proceeding: "This skill is in RED phase (steps not yet implemented). I'll work through its intent manually based on the headings — flag me if my interpretation diverges."
