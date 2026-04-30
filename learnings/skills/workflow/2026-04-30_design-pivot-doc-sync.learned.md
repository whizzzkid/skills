---
skill: wk:workflow
date: 2026-04-30
type: gap
severity: high
---

When implementation diverges from the plan/spec (design pivot), update all affected docs in the same commit — not as a follow-up.

**What happened:** PR #NNN began with a conditional implementation (`if [[ "${CLONE_BRANCH}" != "${$TARGET_BRANCH}" ]]`) described in both spec and plan. A reviewer noted the conditional was unnecessary and the implementation was refactored to an unconditional unified path. However, the spec and plan were not updated in that same commit. Both Copilot and {bot} each independently caught the cross-doc inconsistency, and each required a separate response commit.

**Root cause:** The refactor commit message said nothing about docs. The workflow rule "update docs with code changes" was interpreted narrowly — the author updated the code and tests but treated the spec/plan as separate artifacts to update "later."

**Suggested fix:** When a commit changes the logical structure of a feature (not just a bug fix, but a design redirect), the commit must include updates to:
1. The design spec (`docs/specs/`)
2. The implementation plan (`docs/plans/`)
3. Any inline code comments that reference the old approach
4. Test file comments or test names that reference the old approach

If the spec would require a major rewrite (e.g., pseudocode blocks), add a STATUS UPDATE banner at the top of the doc explaining the design redirect and referencing the commit SHA. Do not leave doc updates for a follow-up commit — reviewers and bots will catch the inconsistency and require another round.
