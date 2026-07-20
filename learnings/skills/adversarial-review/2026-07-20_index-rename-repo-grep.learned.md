---
skill: wk-adversarial-review
date: 2026-07-20
type: gap
severity: medium
---

A migration that renames/drops a DB index or constraint needs a repo-wide grep for the OLD name, not just a diff-scoped sweep.

**What happened:** A migration renamed a unique index and dropped its UNIQUE flag. The diff-anchored review passed, but a schema-enforcement spec in a separate file (not in the migration's diff) still asserted the old index name and its uniqueness, so RSpec went red in CI after a clear verdict.

**Root cause:** Sweep 2.8 (enumeration sync) is applied to the diff surface. Schema/structure specs pin index and constraint names as string literals and live outside the changed files, so a diff-scoped sweep never sees them.

**Suggested fix:** When the diff renames or drops any DB index/constraint (grep the migration for `remove_index`/`rename_index`/`remove_column` + the old `name:`), grep the WHOLE repo for the old identifier string and confirm every hit (especially `spec/**/schema` specs) is updated in the same branch. Treat a surviving literal reference as a blocker.
