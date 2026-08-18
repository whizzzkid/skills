---
class: reference
---

# Coordination with other skills

- **`wk-workflow`** — this skill is a *tool* used inside Phase 5/6. When Phase 6's CI fix
  loop diagnoses a "branch is behind base" failure, invoke `wk-pr-update` rather than
  reinventing the rebase logic.
- **`wk-pr`** — updating an existing PR (not creating one) with a branch behind base →
  invoke `wk-pr-update` first, then resume the rest of its post-creation workflow.
- **`wk-commit`** — the integration commit (patch-replay) and any conflict-resolution
  commits MUST follow `wk-commit`'s rules: signed, conventional format, single emoji, PR
  Sync after push.
