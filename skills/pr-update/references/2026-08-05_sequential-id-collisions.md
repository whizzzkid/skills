---
class: principle
---

# Sequential identifiers conflict before their text does

**Rule** — Before integrating an updated base, compare both histories for new
allocations in every repository-wide sequential namespace. When the same
identifier names different artifacts, move the branch-owned artifact to the
next free value across both histories, reconcile every reference, and commit
that atomic rename before integration.

**Why** — Independently selected next values can merge as semantically distinct
artifacts even when Git reports only a filename or index conflict. Resolving the
identifier namespace before integration keeps references atomic.

**Where** — `SKILL.md` → Stage 1 → Sequential identifier collision pre-flight.
