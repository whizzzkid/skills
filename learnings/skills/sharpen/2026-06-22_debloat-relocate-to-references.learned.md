---
skill: wk-sharpen
date: 2026-06-22
type: pattern
severity: medium
---

De-bloating a SKILL.md over the body-size ceiling: relocate narrow sweep rows to references/ and merge overlapping new rows, rather than mangling dense prose.

**What happened:** A batch sharpen added two new mechanical-sweep rows plus a stance bullet to an `adversarial-review` SKILL.md already near the 24576-byte body ceiling, pushing it ~1.5k over. The Step 7.5 de-bloat pass had to claw back space without dropping any rule.

**Root cause:** The catalog table's rows are information-dense — compressing prose row-by-row risks dropping a distinct check for little byte savings, and is slow. The skill already had an `references/sweep-catalog-extended.md` pattern for "lower-frequency, shape-specific sweeps" that was underused as a relief valve.

**Suggested fix:** When an edit pushes a SKILL.md over a size ceiling, prefer two structural moves over prose-mangling: (1) relocate genuinely narrow, language/tool-specific rows to the existing `references/` extended catalog and update the inline pointer's ID list; (2) merge a conceptually-overlapping new row into the existing row it duplicates (Step 5 merge-overlap). Both are coverage-preserving and reclaim far more bytes per edit than tightening dense rows. Reserve prose compression for the final small margin.
