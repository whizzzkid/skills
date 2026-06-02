---
class: principle
skill: wk-workflow
date: 2026-06-02
severity: medium
---

- **Rule:** When the diff modifies a check/validator/rule file, Phase 1 must
  grep authoring guides (README, `docs/how-to`, repository-check docs) for
  count-enumerations of the rule set ("N things", "three items", numbered
  "you must include" lists) and add each match as an explicit sync target in
  the plan before implementation starts.
- **Why:** A rule added to a check file (4th item) left an authoring guide's
  "three things" list stale; the plan omitted the guide and the adversarial
  sweep caught the drift instead. Phase 1 cross-doc planning only scoped
  spec/plan docs, not count-enumerating authoring guides.
- **Where:** Phase 1 → "Rule-set doc sync probe" (after Spec pre-flight,
  before Plan Presentation).
