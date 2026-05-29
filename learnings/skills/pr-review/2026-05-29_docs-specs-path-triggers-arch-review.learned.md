---
skill: wk-pr-review
date: 2026-05-29
type: correction
severity: high
---

Design spec PRs under `docs/specs/` should auto-trigger wk-arch-review, even when no code changes are present.

**What happened:** Reviewer skipped wk-arch-review on a doc-only PR (`docs/specs/`) because no infrastructure, IaC, or public API changes were visible in the diff. The user corrected this — the spec described system behavior (file-type dispatch) that was architecturally incorrect, and only the arch-review pass surfaced it.

**Root cause:** The wk-arch-review trigger checklist focuses on code-level signals (new service, IaC, trust boundary) and misses design docs whose claims about an existing system may be wrong.

**Suggested fix:** Add `docs/specs/` path match as an unconditional arch-review trigger alongside the existing code-level triggers. A spec that misdescribes the system is as harmful as code that implements it wrong.
