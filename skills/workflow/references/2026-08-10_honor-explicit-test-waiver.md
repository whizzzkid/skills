---
class: one-off
date: 2026-08-10
skill: wk-workflow
---

# Honor explicit user waiver for local tests on low-risk changes

- **Scenario:** User explicitly waived local tests for a static config-list change;
  the workflow began provisioning the full container test environment anyway.
- **Symptom:** Workflow treated its default full-gate guidance as stronger than the
  user's explicit risk judgment.
- **Fix:** When the user explicitly waives local tests, record the waiver, retain
  cheap non-suite validation (syntax check, lint), and proceed to publishing.
- **Why not promoted:** The autonomy rules already say "Execute the workflow without
  asking permission at each step" and stop only for ambiguous plans or design
  decisions. An explicit user direction is neither ambiguous nor optional.
