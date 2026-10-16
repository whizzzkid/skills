---
skill: wk-pr-review
date: 2026-10-15
type: correction
severity: low
verified-against-source: n/a
---

A suggestion fence anchored on one line must contain only that line's replacement.

**What happened:** The first draft of a single-line suggestion fence also repeated the line above the anchor, so
applying it would have duplicated that line.

**Root cause:** The fence was written as a "context + change" snippet instead of an exact replacement for the
anchored range.

**Suggested fix:** Before posting, check that the fence's lines replace exactly `start_line..line`. Any context line
belongs in the range, or should be left out of the fence.
