---
class: principle
---

# Select the last match when the canonical line is emitted last

**Rule:** For a `sed -n 's/.*marker//p'` filter that can match more than one
line, use `tail -1`, not `head -1`, when the canonical summary line is emitted
last by the process. `head -1` returns the first match; an earlier line
containing the same marker (a warning, a config echo) silently wins.

**Why:** A pipeline extracting a path with `… | head -1` picked an earlier
stderr line that coincidentally contained the marker text. The real value was
the process's final summary line. Only use `head -1` when the first occurrence
is authoritative (e.g. a header line).

**Where:** Phase 2 Code Standards, "Parsing tool output" bullet.
