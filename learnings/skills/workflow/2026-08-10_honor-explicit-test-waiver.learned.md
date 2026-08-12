---
skill: wk-workflow
date: 2026-08-10
type: correction
severity: low
verified-against-source: n/a
---

Honor an explicit local-test waiver for a low-risk configuration-only change.

**What happened:** The workflow began provisioning the repository's full container test environment for a static,
syntax-valid configuration list change before the user redirected it to skip the suite and create the PR.

**Root cause:** The workflow treated its default full-gate guidance as stronger than the user's explicit risk judgment
for the requested change.

**Suggested fix:** When the user explicitly waives local tests, record the waiver, retain cheap non-suite validation,
and proceed to the requested publishing step without provisioning the full test environment.
