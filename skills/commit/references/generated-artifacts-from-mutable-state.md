---
class: principle
---

**Rule** — Stage generated artifacts (ORM/type stubs, schema dumps, snapshot
fixtures) one path at a time; never blanket `git add` the generation dir. On a
branch that changes none of an artifact's source, restore it to base
(`git checkout <base> -- <path>`) instead of trusting local regeneration.

**Why** — Artifacts regenerated from mutable local state (dev DB schema, caches)
are not deterministic from the branch's own source. On a shared machine a sibling
branch's migration pollutes the local state, so regeneration emits members absent
from this branch's schema; CI regenerates against clean state and the verify gate
fails on the diff. The existing staged-set check catches strays, not a
legitimately-touched-yet-polluted generated file.

**Where** — wk-commit → "Stage generated artifacts individually" (after "Verify
the staged set before a grouped commit").
