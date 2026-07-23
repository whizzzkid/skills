---
class: principle
---

Keep every doc/spec/test artifact in sync with structural code changes, in the
**same commit** as the code. Applies under Phase 2 authority.

## Design pivots travel with their docs

When a commit changes a feature's logical structure, update every artifact
describing the old shape in the same commit: design spec, implementation plan,
inline comments, test names/comments, ADR, and spec sections enumerating tests.

Triggers: conditional became unconditional, helper lifted/inlined/replaced,
paths merged/split, interface signature changed, state lifecycle moved.

## File/table/test sync

- New file → update the spec's New/Modified Files tables in the same commit.
- Test added/removed/renamed → grep specs/plans/READMEs for the file/function
  and count phrases, update hits in the same commit.
- Renamed string → grep specs for OLD literal incl negative `not_to include`;
  stale negatives pass trivially, losing coverage.
- Major spec rewrite → STATUS UPDATE banner citing the SHA; schedule the full
  rewrite as a follow-up commit.
