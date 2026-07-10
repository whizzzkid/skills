---
skill: wk-adversarial-review
date: 2026-07-10
type: pattern
severity: medium
---

A nil-guard on a schema-nullable JSON/JSONB column must also cover non-object JSON values, not just nil.

**What happened:** A bot flagged `record.json_col['key']` as crashing when the
column is nil (the column had no NOT NULL constraint and no model validation). The
first fix used `json_col&.fetch('key', nil)`, which removes the nil `NoMethodError`
but still raises if the column holds a JSON array (`TypeError`) or a JSON scalar
(`NoMethodError` on `#fetch`). The adversarial subagent caught the residual crash
path as a suggestion; the complete fix was `json_col.is_a?(Hash) ? json_col['key'] : nil`.

**Root cause:** The guard's own justification — "a row written outside the happy
path (backfill, migration, future code) may have an unexpected value" — applies
equally to non-object JSON shapes, not only nil. A `&.` safe-nav guard reasons
about nil alone and silently assumes the non-nil value is the expected container type.

**Suggested fix:** In sweep 2.3 (guard/null-check reachability), when a guard is
added for a schema-nullable structured column (JSON/JSONB/`hstore`), require the
guard to assert the container TYPE (`is_a?(Hash)` / `is_a?(Array)`), not merely
non-nil — the same out-of-band writer that can produce nil can produce a wrong-shaped value.
