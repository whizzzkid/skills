---
class: principle
---

- **Rule** — Before modifying an existing guard/filter/null-check, verify whether the upstream function change already makes the guard correct for new inputs.
- **Why** — A callee now returning valid data for new inputs means existing validity checks already pass; replacing a working guard with a broader one introduces regressions.
- **Where** — `SKILL.md` → Phase 2 → Edit-scope pre-flights → Guard modification.
