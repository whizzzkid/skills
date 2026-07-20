---
class: principle
---

**Rule:** When a migration renames or drops a DB index / constraint / column,
grep the migration for `remove_index`/`rename_index`/`remove_column` + the old
`name:`, then grep the WHOLE repo for the old identifier string. Confirm every
hit — especially `spec/**/schema` structure specs — is updated in the same
branch. A surviving old-name literal is a blocker.

**Why:** Schema/structure specs pin index and constraint names as string
literals and live outside the migration's own diff, so a diff-scoped
enumeration sweep never sees them; the stale literal reddens CI (RSpec) after a
clear review verdict.

**Where:** wk-adversarial-review, Step 2 sweep catalog, row 2.44b
(references/sweep-catalog-extended.md).
