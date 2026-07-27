---
skill: wk-sharpen
date: 2026-07-26
type: gap
severity: medium
verified-against-source: yes
---

A reclaim budget built from hand-retyped "old"/"new" strings priced an edit that was never
made; the verbatim `measure()` disagreed by 3 bytes.

**What happened:** A content-adding fold needed to clear a body ceiling with only 22 B of
headroom and an exhausted reclaim pool, so the addition was paid for by tightening prose
elsewhere in the same file. Both sides of that payment were composed **by hand** in a probe
script — an `old` string retyped to resemble the file's line and a `new` string beside it —
and their byte counts differed by exactly the addition's cost, predicting a net of 0. The
Edit that actually landed replaced only the middle of that span, not the whole retyped line,
so the real saving was smaller. Re-running the size hook's `measure()` verbatim over the
staged blob returned a body 3 B **above** the baseline, not equal to it. A further 3 B tighten
restored net 0.

**Root cause:** the retyped `old` string was a plausible reconstruction of the line rather
than its bytes, so the delta it produced described a hypothetical edit. The existing rules
require the single post-staging measurement to run `measure()` verbatim, and separately
require grep *needles* to be taken from a file's bytes rather than a tool's rendering — but
nothing requires the **inputs to the byte arithmetic** to be extracted from the file. A
hand-composed delta therefore enters the budget with the same authority as a measurement,
and its error is invisible until the one real measurement at the end.

**Why it matters:** here the error was absorbed by 22 B of headroom. The rule that generates
this situation — measure before drafting, then stage addition and reclaim together and
measure exactly once — is specifically invoked when headroom is nearly zero. At 0 B clear,
the same 3 B slip is a ceiling breach surfacing only at the commit hook, after the fold is
written and the version bumped.

**Suggested fix:** require both sides of any reclaim or addition estimate to be derived from
the file itself — slice the exact span out of the file rather than retyping it, or take a
baseline `measure()` and an applied `measure()` and diff those. State a hand-composed delta
as an estimate to be reconciled against the single verbatim measurement, never as the budget
itself, and re-tighten if the two disagree.
