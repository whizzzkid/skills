---
skill: wk-grep
date: 2026-07-26
type: gap
severity: medium
verified-against-source: yes
---

Newline-normalizing prose to defeat a wrapped-needle false zero structurally caps `grep -c`
at 1 — the remedy for one counting defect silently introduces another.

**What happened:** A landing check ran a needle both ways against a hard-wrapped skill file.
Line-oriented `grep -c` returned 2; the newline-normalized pipeline
(`tr '\n' ' ' | tr -s ' ' | grep -c`) returned 1 for the same needle. The two numbers look
like a contradiction inviting an investigation into which one is wrong. Neither is wrong:
`grep -c` counts *matching lines*, and normalization collapses the whole file to a single
line, so the normalized count can only ever be 0 or 1 regardless of how many occurrences
exist.

**Root cause:** Confirmed by direct reproduction, not inferred. A three-line fixture with
one occurrence per line: line-oriented `grep -c` → `3`; normalized `grep -c` → `1`;
normalized `grep -o pat | wc -l` → `3`. The normalization is correct and necessary — it is
what makes a cross-wrap needle matchable at all — but it destroys the very unit `-c` counts.
The defect is silent at rc=0 with a plausible small integer, so it has the same shape as the
`-l`/`-c` flag-pair cap: a wrong number, not a missing one, with nothing about it signalling
corruption.

**Collides with an existing family rule:** The rule "require a control to reach a known
*true* count, not merely a changed one" is **unsatisfiable by construction** against a
normalized pipeline whenever the expected count exceeds 1 — the assertion reads as a
permanent failure with no defect behind it, tempting the reader to explain it away or to
weaken the control back to "the count changed". This mirrors exactly how a capped `-lc`
counter makes a ">1" control unsatisfiable, so the family now has two independent mechanisms
defeating the same control criterion from different directions.

**Suggested fix:** State that a normalized match answers **presence only**. Keep the
normalized pipeline for the presence question a coverage or landing proof actually asks, and
switch to `grep -o pat | wc -l` when multiplicity is the question — or count on the
un-normalized text when the needle is known to fit within one line. Where a control must
assert a known true count, assert it against a form whose counting unit survives the
transform; never against `-c` over a stream the pipeline has already collapsed to one line.
