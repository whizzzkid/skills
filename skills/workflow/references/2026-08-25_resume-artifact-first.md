---
class: principle
source: learnings/skills/workflow/2026-08-25-resume-artifact-first.md
---

# Recover named handoff artifacts before inferring continuation

On ambiguous continuation requests, inspect the workspace for plan and
handoff files before selecting a workflow phase from branch state alone.
Session recovery should locate concrete artifacts from the prior run, not
just inspect Git state and generic memory.
