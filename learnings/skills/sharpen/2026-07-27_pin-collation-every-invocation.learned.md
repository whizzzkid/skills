---
skill: wk-sharpen
date: 2026-07-27
type: gap
severity: medium
verified-against-source: yes
---

The collation pin is written as a property of *the* marker-diff pipeline, so an ad-hoc second
`comm` in the same run inherits none of it — and that second `comm` is usually the control arm.

**What happened:** A Source 3 memory scan applied the "pin `LC_ALL=C` on the comparison, not
only on the sorts" rule correctly to the documented marker diff, which returned a clean zero.
The same script then reconciled the parse gate's reject list with a *second*, ad-hoc
comparison — `comm -13 <listing> <all-files>` — written with `LC_ALL=C` on both `sort`s and
**not** on the `comm`. It emitted 6 rows where the truth was 2. The four surplus rows were
files the gate had just *accepted*, i.e. present on both sides, so the reject list claimed as
out-of-scope four memories that were in scope.

Caught only because the reject list was self-evidently implausible — it named files the run
had accepted one step earlier. Re-running the identical inputs under `LC_ALL=C comm` returned
2, and `grep -Fxq` confirmed each of the four surplus rows was present in the listing, proving
them false rather than a real finding. Arms: unpinned 6, pinned 2.

**Root cause:** Verified by driving both arms directly over the same two files, not inferred.
The rule and its folded form are both attached to a *named pipeline* ("the marker diff"), so
they read as a property of one documented invocation rather than of every collation-sensitive
consumer the run creates. A reconciliation or control comparison added beside the real one is
never the invocation the reference snippet shows, so it acquires the pinning only if the
author generalizes the rule unprompted. That is the worst place for the gap to land: the
reconciliation arm exists precisely to validate the primary result, so an un-pinned sibling
puts a mis-walking comparison in the position of the check.

Visible only by luck here. The store's sole uppercase-initial resident is its hand-maintained
index, and that entry is exactly the element which *differs* between the two streams — the
condition a control needs to reach the comparison at all. Had the reject list been
all-lowercase, both arms would have agreed and the defect would have stayed hidden behind a
correct-looking answer.

**Suggested fix:** State the pin as a per-invocation property rather than a pipeline property:
every `comm` / `join` / `uniq` the run executes — including ad-hoc reconciliation arms, control
arms, and one-off sanity checks — carries the same `LC_ALL=C` as the sorts feeding it, not just
the invocation shown in the reference snippet. Add the converse tripwire: a reconciliation
result that contradicts a verdict the run already reached (here, a reject list naming accepted
files) indicts the reconciliation's own invocation form first, before the verdict it questions.
