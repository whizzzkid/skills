---
skill: wk-adversarial-review
class: principle
---

**Rule** — Add a mechanical sweep (catalog row 2.67): when a migration adds or
changes a load-bearing schema invariant — a CHECK constraint, a non-unique index
backing an app-enforced (no-FK) association, a load-bearing column default, or an
append-only table (`created_at`, no `updated_at`) — grep the repo's
schema-guard/lock spec for a matching assertion; absent → test-coverage finding.
Sibling: a `t.string` column whose comment documents pipe-delimited enum values
but has no matching `add_check_constraint`.

**Why** — The migration itself is correct, so a code-path coverage sweep passes,
but nothing locks the invariant: a later migration dropping the constraint/index/
default passes silently. The invariant is only regression-safe once a spec
asserts it.

**Where** — wk-adversarial-review Step 2 extended sweep catalog (row 2.67).
