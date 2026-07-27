---
class: principle
---

**Rule** — Count a newline-normalized stream with `grep -o … | wc -l`, never `grep -c`.
Normalizing collapses the whole input to a single line and `-c` counts *matching lines*, so
it structurally caps at 1 however many occurrences exist:

```sh
# fixture: three lines, one occurrence of the needle on each
grep -c needle f                                  # 3   — true count
tr '\n' ' ' < f | tr -s ' ' | grep -c needle      # 1   — capped by construction
tr '\n' ' ' < f | tr -s ' ' | grep -o needle | wc -l   # 3 — true count preserved
```

**Why** — The remedy for one counting defect silently installs the next. Newline
normalization is *correct and necessary* — it is the only way a needle spanning a hard wrap
becomes matchable at all — but it destroys the very unit `-c` counts. The defect is silent
at rc=0 behind a plausible small integer, exactly the `-lc` shape: a **wrong number, not a
missing one**, with nothing about it signalling corruption.

**Resolves a live tension between two family rules** — The "require the control to reach a
known *true* count, not merely a changed one" rule and the wrapped-prose normalization rule
were folded a day apart and collide: against a normalized pipeline, any expected count
above 1 is **unsatisfiable by construction**, so the assertion reads as a permanent failure
with no defect behind it. That tempts a reader to explain it away and weaken the control
back to "the count changed" — the precise regression the true-count rule exists to prevent.
The fix belongs on the normalization rule (which prescribes the pipeline) rather than on the
true-count rule (which is correct as written), so the prescription itself now names the
surviving counting form and cross-references the true-count rule instead of restating it.

**Verified against source** — Reproduced directly, not inferred. Three-line fixture, one
occurrence per line: line-oriented `grep -c` → `3`; newline-normalized `grep -c` → `1`;
normalized `grep -o … | wc -l` → `3`. The landing check for this learning was itself run
through the corrected form, with a must-hit control (a phrase known present in the target
file) returning 1 and a must-miss control returning 0 in the same normalized invocation.

**General form** — A count is evidence only where its counting unit survives every transform
applied upstream of it. Stated this way it covers the non-`grep` instances of the same shape
(`wc -l` after a join, `sort -u` after a case-fold, `uniq -c` over a re-wrapped stream)
without naming them, and it composes with the existing "matcher's unit must be at least as
large as the needle" rule rather than duplicating it.

**Where** — wk-workstyle-shell → Rules: folded into the existing hard-wrapped-prose bullet
(the one prescribing the normalization) rather than added as a separate rule, keeping the
prescription and its counting caveat in one place; mirrored into the README's "Rules at a
Glance", whose copy of the same prescription carried the identical stale `then grep -c`.

**Ownership note** — The `skill:` field named `wk-grep`; no such skill or `skills/grep/` dir
exists, so it was treated as the reporter's guess rather than a resolved target. Routed by
subject grep to the skill already owning the silent-failure / matcher-dialect family — the
same routing all three siblings took (ERE `\|` literal pipe, `grep -lc` capping at 1,
wrapped-prose false zero). Extended that fold's existing uncommitted edit and advanced its
single version bump rather than opening a competing one.
