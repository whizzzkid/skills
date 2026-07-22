---
skill: wk-adversarial-review
date: 2026-07-22
type: pattern
severity: medium
---

Rails `db/schema.rb` version-line merge conflicts must resolve to the HIGHER timestamp AND verify both sides' tables are present.

**What happened:** Two branches each added a migration; `main` merged one with a later timestamp after the feature branch had already bumped `schema.rb` to its own (earlier) migration. The merge conflicted only on the `ActiveRecord::Schema[..].define(version: <ts>)` line. Correct resolution: take the higher `<ts>` (the latest migration across both sides), then confirm the merged schema body still contains BOTH sides' `create_table`/`t.index` blocks — the version line is just a high-water mark, not proof the tables merged.

**Root cause:** The `version:` integer is the max migration timestamp; a naive "keep ours" or "keep theirs" silently drops the other side's table definitions or leaves the version lying about which migrations are applied. Sweep 2.44 (merge-conflict resolution) covers call-site arg drift but this schema-specific shape needed an explicit both-tables-present check.

**Suggested fix:** On a `schema.rb` version conflict, resolve to the higher timestamp, then grep the merged file for every `create_table`/index the diff of each parent added and confirm all are present before committing. Cross-check that each parent's migration FILE is present under `db/migrate/` and reflected in the schema.
