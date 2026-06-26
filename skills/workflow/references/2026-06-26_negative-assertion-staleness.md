---
class: principle
date: 2026-06-26
---

**Rule:** After renaming or reformatting a user-facing string, grep the spec
files for the OLD literal — and update negative assertions (`not_to include`,
`refute_match`, etc.) that reference it, not just positive `include` assertions.

**Why:** A negative assertion whose match string is the old literal keeps passing
after the rename, but for the wrong reason — it no longer guards the text it was
written to test. Coverage is silently lost while the suite stays green.

**Where:** Phase 3 / "File/table/test sync" — grep the old literal across specs,
positive and negative assertions alike, in the same commit as the rename.
