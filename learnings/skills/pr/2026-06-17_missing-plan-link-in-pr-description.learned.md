---
skill: wk-pr
date: 2026-06-17
type: gap
severity: medium
---

PR description did not reference the implementation plan document the work was derived from.

**What happened:** The PR body linked to a high-level vision spec but omitted the concrete implementation plan (`docs/plans/`) that defines the specific phase (checkboxes, acceptance criteria, ticket). The user had to point this out manually.

**Root cause:** Step 2 (PR body composition) does not explicitly require locating and linking the implementation plan file. The skill says to populate every section from "diff and commit history" but doesn't prompt the agent to search `docs/plans/` for a plan document covering the current phase.

**Suggested fix:** In the Resolve PR Body Template step, add an explicit pre-flight: search `docs/plans/` and `docs/specs/` for any file whose content references the branch's phase/feature. If found, link both the plan (with anchor to the relevant phase section) and the spec under a `## Meta` block. A plan doc is the authoritative source of acceptance criteria and should always be surfaced when one exists.
