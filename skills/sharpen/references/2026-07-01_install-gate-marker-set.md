---
class: principle
---

**Rule:** The Step 8 install gate accepts either `Done!` or `Installed <N>
skills` (N ≥ 1) as proof of success — probe for a marker set, not a single
literal.

**Why:** The skills CLI's terminal success marker changed across versions
(`Done!` → `Installed N skills`). A single hard-coded literal check yields a
false-negative and triggers redundant re-runs to hunt for a string the CLI no
longer prints.

**Where:** wk-sharpen Step 8 item 1 (Install).
