---
class: principle
skill: wk-workflow
date: 2026-06-01
severity: high
---

- **Rule:** Before every `wk-commit` on a code diff, explicitly call
  `Skill(wk-workstyle)` as a non-skippable HARD-RULE gate — same framing
  as the Phase 4 adversarial-review gate.
- **Why:** "Auto-invoked" in a skill's own description is aspirational;
  code shipped with a semantically inaccurate variable name because the
  workflow had no enforceable workstyle step. A mandatory step in the
  calling skill is enforceable where a frontmatter promise is not.
- **Where:** Phase 2 (Implement) step 2 — strengthened from a soft
  "auto-fires" bullet into a HARD RULE gate. [[2026-06-01_semantic-naming-accuracy]]
