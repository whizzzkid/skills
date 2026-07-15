---
skill: wk-commit
date: 2026-07-15
type: gap
severity: low
---

User-requested in-repo grounding/reference docs are not ephemeral scratch — stage them by default.

**What happened:** A task asked to collect reference material into a specific in-repo directory before writing the deliverable. Applying the "exclude ephemeral working docs" rule, the agent committed only the deliverable and left the reference directory uncommitted. The user had to ask twice ("did you commit the references?", then "add that too") to get them included.

**Root cause:** The "exclude ephemeral working docs" guidance treats agent-authored planning/scratch artifacts as non-history, but did not distinguish those from artifacts the user *explicitly requested be created at an in-repo path* — which are intended deliverables, not scratch.

**Suggested fix:** In the "Exclude ephemeral working docs" section, add: when the user explicitly directs artifacts to a specific in-repo path (not a known-ephemeral dir like `docs/plans/`), treat them as intended deliverables and stage them with the work by default; do not silently withhold them as scratch.
