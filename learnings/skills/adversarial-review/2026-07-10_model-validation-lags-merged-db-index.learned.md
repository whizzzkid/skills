---
skill: wk-adversarial-review
date: 2026-07-10
type: gap
severity: high
---

A merge that brings in a new DB UNIQUE index leaves the model layer without a matching uniqueness validation — duplicates then raise an unhandled `RecordNotUnique` instead of a graceful validation failure.

**What happened:** Base-branch hardening added a composite UNIQUE index. After merging base into the feature branch, the ActiveRecord model still validated only its original unique columns; the new composite index had no corresponding `validates ... uniqueness: { scope: }`. Callers hitting a duplicate would get a DB-level exception, not a validation error.

**Root cause:** Post-merge review focused on conflict resolution and did not re-audit model↔schema parity for constraints introduced by the *incoming* side.

**Suggested fix:** When a merge/rebase introduces a new UNIQUE (or CHECK) DB constraint, adversarial review must diff every unique index against the model's `validates ... uniqueness` declarations and flag any index without a mirror — the parity invariant "every unique index has a model validation" is checkable mechanically.
