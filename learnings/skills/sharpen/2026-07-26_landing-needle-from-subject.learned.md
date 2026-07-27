---
skill: wk-sharpen
date: 2026-07-26
type: gap
severity: medium
verified-against-source: yes
---

A landing check keyed on a supplied slug→line map proves only that the *line* is new, never
that *that learning's* principle landed — the map is an unverified hint, not an index.

**What happened:** A batch run inherited a set of learnings described as already folded into
an uncommitted worktree fold, together with a per-slug → line-number map. The landing check
walked the map, cut the full line at each named number, and scored it PRESENT-in-worktree /
ABSENT-at-HEAD with a live unchanged-region control. Every entry passed. Printing each line's
*content* alongside its slug then showed the map was scrambled: the line attributed to one
slug carried a different learning's principle entirely, and that slug's actual subject had
landed elsewhere in the file. The full set was in fact present, so the verdict happened to be
right — but it was right by luck. Had one principle genuinely not landed, the same check would
still have returned all-FOLDED, because every line in a newly-rewritten region is new
regardless of which lesson it encodes.

**Root cause:** The landing rule fixes *which copy* to read (worktree bytes, not installed or a
tool's rendering) but leaves the needle's *provenance* unconstrained, so a caller-supplied line
number gets treated as an index into the fold. Novelty of a line and presence of a principle are
different propositions: in a fold that rewrites a contiguous span, per-line novelty is
near-tautological and carries almost no information about coverage. A supplied map is the same
class of artifact as a field report's root cause — a reporter's inference about where something
went, which the owning source can contradict.

**Suggested fix:** Require the landing needle to be derived from the learning itself: read each
source learning, extract its distinctive subject term, and grep *that* against the worktree
bytes — location discovered, never supplied. Treat any slug→line map as an unverified hint under
the existing report-is-a-hypothesis rule; a mismatch between the map and where the subject
actually matches is a stale-map signal to report, not a failure to chase. State explicitly that a
per-line novelty check is necessary but not sufficient: it corroborates that a fold touched the
region, and only a subject-keyed match certifies the lesson landed. Rendering the matched text
next to its slug (rather than a bare rc) is what makes a mis-attribution visible at all.
