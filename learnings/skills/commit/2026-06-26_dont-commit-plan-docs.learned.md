---
skill: wk-commit
date: 2026-06-26
type: correction
severity: medium
---

Plan documents staged and committed as if they were spec artifacts.

**What happened:** A `docs/plans/` file was committed to the PR branch. The repository only commits specs (`docs/specs/`); plan docs are ephemeral working artifacts and must not appear in git history.

**Root cause:** No convention check exists before staging `docs/plans/`. The agent staged everything under `docs/` without distinguishing plan from spec.

**Suggested fix:** Before `git add` on any `docs/` file, confirm it is under `docs/specs/` (or the repo's settled spec layout). Files under `docs/plans/` are working artifacts — exclude them, or at minimum surface a warning before staging.
