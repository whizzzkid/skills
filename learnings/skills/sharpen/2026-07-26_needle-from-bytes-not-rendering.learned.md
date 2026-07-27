---
skill: wk-sharpen
date: 2026-07-26
type: gap
severity: high
verified-against-source: yes
---

A landing check built its needles from a tool's rendered output; the display layer had
silently normalized that text, so two fixed-string greps reported MISSING against content
the file genuinely contains.

**What happened:** A run confirming whether folds had landed took the literals it grepped
for from what a `Read` call displayed, rather than from the file's bytes. The harness had
*compressed* that rendering. The dropped material included articles — a source phrase
reading "Pin the locale on the comparison" rendered without its "the"s — so two
`grep -F` needles could not match text that is present on disk. The failed-control rule
caught it: the same invocation form was proven able to return a hit, which indicted the
needles rather than the file.

**Root cause (verified, and broader than first framed):** the transcript's rendering layer
mutates tool results three distinct ways, all silent and all unsignalled:

- elides whole spans, replacing them with a compression marker;
- drops function words (articles, auxiliaries) from otherwise intact prose;
- joins lines, so a needle spanning a source line break matches nothing.

Reproduced first-hand while distilling: a `Read` of a `SKILL.md` returned elision markers
for multi-hundred-byte spans, and a `sed` of a reference file returned articles dropped and
lines joined. That second observation matters — it establishes the defect as a property of
the **transcript's rendering of any tool result, Bash stdout included**, not of the `Read`
tool specifically, which is how it was first reported.

**Distinct from the already-folded escaping variant:** that case mis-*escaped* a correctly
sourced literal (a regex `.` where the source has `**`) — right bytes, wrong pattern. This
is the mirror: right pattern, wrong *source* for the literal. Escaping discipline cannot
catch it, because a needle taken from a lossy rendering is already the wrong string before
escaping is even applied.

**What should have happened:** the needle should have been cut from the file's bytes
(`command grep -o`, or a byte read) and the comparison run in-shell, so that only the
verdict — never the literal — crosses the display layer.

**Why it matters:** the failure is silent and inverts the landing verdict in the dangerous
direction. A fold that *did* land reads as missing, which invites a re-fold and a competing
edit into a tree already carrying prepared, path-disjoint folds.
