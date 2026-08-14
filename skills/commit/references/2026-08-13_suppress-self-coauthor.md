---
class: principle
skill: wk-commit
date: 2026-08-13
severity: medium
---

- **Rule:** Skip `Co-authored-by:` for the current user when they match the PR
  author — the commit already carries correct authorship via git config.
- **Why:** Agent misapplied wk-pr-resolve's co-author directive without checking
  `$CURRENT_USER == $PR_AUTHOR`. wk-pr-resolve already guards this (`!=` only),
  but wk-commit as trailer gatekeeper needs its own defense-in-depth check.
- **How applied:** Added bullet to the closed-trailer-set HARD RULE in SKILL.md.
