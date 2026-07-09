---
skill: wk-adversarial-review
date: 2026-07-09
type: gap
severity: medium
---

A migration adding a load-bearing schema invariant (CHECK constraint, non-unique association index, column default, or an intentionally-absent column) is a regression risk unless a schema-guard spec asserts it, even when the migration itself is correct.

**What happened:** A migration-only PR added DB-level CHECK constraints and relied on non-unique indexes, column defaults, and an append-only (no `updated_at`) invariant. The schema-guard spec locked indexes/NOT-NULL/no-FK but not the new invariants, so a later migration dropping any of them would pass silently. The fresh subagent flagged the coverage gap by name.

**Root cause:** The sweep catalog checks test coverage of code paths but has no explicit trigger for "schema invariant added in a migration but not asserted in the repo's schema-lock spec." DB-enum-documented-in-comment-only (no CHECK constraint) is a sibling gap in the same family.

**Suggested fix:** Add a sweep row: when a migration adds/changes a CHECK constraint, non-unique index backing an app-enforced (no-FK) association, load-bearing default, or an append-only table (created_at, no updated_at), grep the repo's schema-guard spec for a matching assertion; absent → test-coverage finding. Also flag `t.string` columns whose comment lists pipe-delimited enum values but have no matching `add_check_constraint`.
