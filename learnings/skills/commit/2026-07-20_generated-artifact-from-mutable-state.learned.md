---
skill: wk-commit
date: 2026-07-20
type: gap
severity: high
---

Never blindly `git add` a generated artifact whose content derives from local mutable state (a dev database, a cache) — verify it against the base branch first.

**What happened:** A branch that changed no ORM models committed a regenerated type-stub / RBI file swept in by a blanket `git add <generated-dir>`. The stub had been regenerated against a shared local dev DB that carried an unrelated, unmerged branch's migration, so it gained accessor methods for columns that do not exist on this branch's schema. CI regenerated the stub against a clean DB built from only this branch's migrations, and the verify gate failed on the diff.

**Root cause:** Generated artifacts derived from mutable local state (dev DB schema, caches) are not deterministic from the branch's own source. A blanket `git add` of the generation output dir assumes the local state matches the branch — false on a shared machine where sibling branches have applied migrations. The existing "verify the staged set before a grouped commit" guidance catches strays but not a *legitimately-touched-yet-polluted* generated file.

**Suggested fix:** Add a wk-commit rule: when staging generated artifacts (ORM/type stubs, schema dumps, snapshot fixtures), stage them individually — never a blanket `git add` of the generation dir. On a branch that changes no models, restore any model-derived stub to the base branch's version (`git checkout <base> -- <path>`) rather than trusting local regeneration; only artifacts genuinely changed by this branch's source (e.g. route-helper stubs for a routes-only PR) should differ from base.
