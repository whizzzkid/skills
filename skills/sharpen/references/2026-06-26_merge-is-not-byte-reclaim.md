---
class: principle
date: 2026-06-26
---

**Rule:** A pure row/bullet merge reclaims only scaffolding bytes (~3 B — the
`- ` prefix + one newline), not content. When a near-ceiling fold needs a
net-negative byte change, the reclaim must remove content: a redundant-restatement
trim, a relocation to `references/`, or a genuinely dropped duplicate clause. A
merge counts toward reclaim only when it also drops the now-duplicated phrase.

**Why:** Step 7.5 listed "merge a new row into the existing row" among byte-reclaim
structural moves, conflating "structural move" with "byte reclaim." A merge that
preserves every word deletes almost nothing, so it under-shoots the budget and
reopens the measure-and-trim loop the step forbids.

**Where:** Step 7.5 — "Prefer content-removing structural moves over prose-mangling
to reclaim bytes." Merge demoted from the numbered reclaim list to a caveat.
