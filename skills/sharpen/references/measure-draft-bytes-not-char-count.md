---
class: principle
---

**Rule** — Before picking a reclaim quantity for a near-ceiling fold, measure the
drafted addition's actual bytes (stage the draft, or diff the staged blob). Never
eyeball or char-count it.

**Why** — Char count under-shoots byte size: `→` is 3 UTF-8 bytes (not 1), and
backticks/punctuation push a line past its visible length. Two byte-budget
under-shoots in one fold are the measure-and-trim re-violation Step 7.5 forbids.

**Where** — Step 7.5, "measure exactly once" sub-bullet under the hard size ceiling.
