---
skill: wk-pr-review
date: 2026-07-15
type: correction
severity: high
---

Skipped the mandatory arch-review sub-step for a PR that added a new `docs/specs/` design doc; the user had to ask "did you do an arch review of the doc?"

**What happened:** The PR added a new spec under `docs/specs/`. Phase 1 has a HARD RULE that any changed file matching `docs/(specs|adr|arch|design|rfc)/` unconditionally triggers wk-arch-review before Phase 3, but the review ran straight through to composing comments without invoking it.

**Root cause:** The arch-review trigger check was treated as conditional/skippable when the diff "looked like" a routine code review, ignoring that a spec-doc addition is an unconditional trigger regardless of the rest of the diff.

**Suggested fix:** In Phase 1, before Phase 3, mechanically grep the changed-file list for `docs/(specs|adr|arch|design|rfc)/` (and the filename-keyword triggers) and invoke wk-arch-review when any match — make it a checklist item that cannot be skipped, not a judgment call.
