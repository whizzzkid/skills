---
class: principle
---

- **Rule:** Classify every distilled lesson as `principle` or `one-off` before drafting a SKILL.md edit. `principle` → fold into SKILL.md + write a reference. `one-off` → write a reference only, skip Step 4, no version bump.
- **Why:** Every learning landing inline grows SKILL.md unbounded; narrow-context recipes do not generalize and crowd out the load-bearing rules. The references/ dir is the right home for low-frequency, repo-specific, or tool-version-specific recipes — agents that hit the exact scenario can find them; agents on the common path are not distracted by them.
- **Where:** Step 3 → new sub-section "Classify: principle vs one-off" (HARD RULE) with two routing rules and criteria. Step 4 opening: skip for `one-off`. Step 7 reference rules: split frontmatter (`class:`) and required-section shape by class.
