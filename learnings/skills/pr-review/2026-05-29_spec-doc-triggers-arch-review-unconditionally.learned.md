---
skill: wk-pr-review
date: 2026-05-29
type: correction
severity: high
---

Any PR whose diff is primarily or entirely a design spec MUST trigger wk-arch-review — doc-only is not a reason to skip it.

**What happened:** Reviewer classified a `docs/specs/` PR as "doc-only, no architecture change" and skipped wk-arch-review. The user corrected this explicitly. The arch pass then found a high-severity finding: the spec misdescribed the engine's file-type dispatch as a pipeline capability when the engine does none — a design-model error that would have caused the implementation plan to chase non-existent plumbing work and shipped under-specified eval gates for the only blocker-severity section.

**Root cause:** The arch-review trigger checklist in wk-pr-review checks for code signals (IaC, new service, trust boundary, data contract). A spec doc that *describes* system behavior is architecturally load-bearing but leaves no code footprint in the diff, so it passed through all existing trigger checks.

**How to apply:** When the diff is a `docs/specs/` file (or any file matching `docs/(specs|adr|arch|design|rfc)/`), invoke wk-arch-review unconditionally — before Phase 3 investigation, alongside the doc-relocation audience scan. Do not treat "doc-only" as evidence that no architecture is at stake; specs are often the *only* place the architecture is stated.
