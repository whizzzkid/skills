---
skill: wk-sharpen
class: principle
---

**Rule** — The `LC_ALL=C` pin is a property of **each collation-sensitive invocation**, not
of the named marker-diff pipeline. Every `comm` / `join` / `uniq` the run executes — ad-hoc
reconciliation arms, control arms, one-off sanity checks — carries the same pin as the sorts
feeding it, not only the invocation the reference snippet shows.

**Why** — The inline rule and the reference snippet both attached the pin to *the* marker
diff, so it read as a property of one documented invocation. A second, ad-hoc comparison
added beside the real one is never that invocation, so it acquires the pin only if the
author generalizes unprompted. That is the worst place for the gap to land: the
reconciliation arm exists precisely to validate the primary result, so an unpinned sibling
puts a mis-walking comparison in the position of the check. Observed arms: unpinned 6 rows,
pinned 2, where the four surplus rows were files the gate had just *accepted*.

**Converse tripwire** — A reconciliation result that contradicts a verdict the run already
reached indicts the reconciliation's own invocation form first, before the verdict it
questions.

**Classification note** — Folded as a *scope gap*, not a re-violation, so no escalation notch
was spent. The rule fired correctly on the documented pipeline (positive-steering evidence);
what failed was its scope, which covered one named invocation rather than every consumer the
run creates. Escalation is for a rule that failed where it already applied.

**Byte routing** — The inline `SKILL.md` bullet took the scope widening (the load-bearing
half) within the size ceiling; the tripwire and the reconciliation-arm rationale went to the
linked shared reference [`memory-marker-diff.md`](memory-marker-diff.md), which is a runtime
pointer rather than a per-learning record.

**Where** — wk-sharpen batch mode, Source 3 marker diff.
