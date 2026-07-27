---
skill: wk-grep
date: 2026-07-26
type: gap
severity: medium
verified-against-source: yes
---

A line-oriented grep returns a false zero when the target sentence is hard-wrapped across
lines — the miss is indistinguishable from genuine absence.

**What happened:** A pass needed to prove that four inline rules were each stated *in full*
by an already-linked reference file before deleting the inline copy (a coverage proof, where
a zero is load-bearing: it means "not covered, do not delete"). Two of the four greps
returned 0. Both zeros were **false**. The reference files are prose hard-wrapped at ~90
columns, so a sentence like `route \`grep\` to a different implementation` is split across
two physical lines with a newline plus leading indent in the middle. `grep` matches within a
single line, so no line contains the whole phrase. Re-running against newline-normalized
text (`tr '\n' ' ' | tr -s ' '`) returned 1 for both, with a deliberately-absent control
string still returning 0 — confirming the normalization had not simply made everything match.

**Root cause:** Confirmed by reproduction, not inferred. The needle spanned a hard wrap in
the source file. `grep`'s matching unit is the line; any multi-word needle longer than the
remaining columns on a wrapped line can never match, regardless of the pattern being correct.
Prose reference files are wrapped by convention while the phrases quoted from them are not,
so the two are systematically mismatched — this fails silently and repeatably, not
occasionally.

**Suggested fix:** When grepping *prose* (as opposed to code or single-token identifiers),
normalize line breaks before matching: `tr '\n' ' ' | tr -s ' '` then `grep -c`. State that a
zero from a line-oriented grep over wrapped prose is **unverified** until either re-run
normalized or corroborated. Pair every load-bearing zero with a control in the same
invocation form — a needle known to be present (must hit) and one known absent (must miss) —
because normalization can convert a false zero into a false positive if it also collapses
structure the needle relied on. The general shape: the matching unit of the tool must be at
least as large as the needle, and prose wrapping silently violates that.
