---
class: principle
date: 2026-05-28
source:
  - ~/.claude/memory/feedback_dont_simplify_away_warnings.md
severity: medium
---

- **Rule** — preserve `warn` / `logger.*` / `puts` / `console.*` diagnostic calls when collapsing an `unless`/`if` block into a guard clause.
- **Why** — silent diagnostic loss is a debuggability regression: behavior may be preserved but the operator-visible signal is gone, and tests rarely cover log output.
- **Where** — Stage 2 removed-line audit table in `wk-refactor` SKILL.md (new row for diagnostic calls inside removed blocks).
