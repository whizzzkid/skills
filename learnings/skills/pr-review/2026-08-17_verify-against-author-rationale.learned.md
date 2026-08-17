---
skill: wk-pr-review
date: 2026-08-17
type: pattern
severity: medium
verified-against-source: yes
---

Findings that contradict a number or a constant must be checked against the author's own
derivation in the diff before drafting — subagent hits there are disproportionately misreads.

**What happened:** Two would-be findings in one review were refuted by reading the diff more
carefully, both surfaced by delegated audits or first-instinct reasoning:

1. A doc audit reported `119x41` as an off-by-one against the same document's stated
   "maximum 40 tool calls". The `41` was correct: the doc states elsewhere that acting on a
   tool result costs an additional call, so a 40-tool-call session implies 41 API calls. The
   audit quoted the table row but not the derivation rule two sections away.
2. I was about to suggest replacing a fixed settle delay with a bounded poll-and-retry on a
   cache-read gate — the obvious fix for a timing-sensitive assertion. The constant's own doc
   comment carried the measurement that kills it: each probe attempt *writes* the segment it
   failed to read, so a retry reads its own predecessor's write and passes whether or not the
   thing under test ever worked. Retrying would have silently voided the gate.

**Root cause:** Phase 3 delegates finding-generation but the returned findings carry only the
line they anchor to. Two review-specific classes are especially prone to this: (a) arithmetic
in prose, where the derivation rule usually lives in a different section than the figure, and
(b) "just retry it / just make it configurable" fixes for timing constants, where a careful
author has often pre-refuted the obvious fix in the comment directly above the constant.
Neither class is caught by the existing empirical-pass rule, which targets executable logic.

**Suggested fix:** In Phase 4, before drafting any comment that asserts a number is wrong or
proposes replacing a constant, read the full surrounding comment block and grep the artifact
for the derivation rule behind the figure. Add the corollary: when such a finding is refuted
but the derivation was *unstated* and demonstrably misled an automated reader, do not drop it
— reframe it as a low-severity clarity suggestion ("spell out that 41 = 40 + 1"), which is
the genuinely useful residue of the false positive. Both outcomes are better comments than the
original claim; neither is a silent skip.
