---
class: principle
skill: wk-adversarial-review
date: 2026-06-29
---

**Rule** — When a diff adds or extends a generator/automation that writes a value
(count, version, enumerated list) into a file, treat the tool as the source of
truth for that value: grep every other file for the same value and confirm the
same automation updates each consumer. Flag any consumer left hand-maintained.

**Why** — A generator updated a count in file A but not file B; the value drifts
the moment the count changes. Line/diff-scoped review misses it because the
unupdated consumer is never read — this needs intent-aware cross-file reasoning
about who owns a shared value. Recurs whenever automation is added incrementally.

**Where** — Extended sweep catalog, row 2.59 (shape-specific, routed to the
extended file; ID registered in the SKILL.md inline pointer).
