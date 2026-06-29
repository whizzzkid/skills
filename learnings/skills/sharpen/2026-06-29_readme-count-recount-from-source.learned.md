---
skill: wk-sharpen
date: 2026-06-29
type: gap
severity: medium
---

When a sharpen edit changes a catalog/list size, recount the README's documented count from source — never trust the existing number.

**What happened:** Folding a learning added two sweep rows to a skill. The sibling README cited the row count in two places. The documented count was already stale (real total was 3 higher than the README's number) before the edit — so a naive "+2" bump would have produced a still-wrong count. Recounting the actual rows from both the inline and extended catalog gave the correct total.

**Root cause:** The Step 7 "Sync skill README" drift check lists Version, tables, and descriptions, but does not call out free-standing numeric counts embedded in README prose/diagrams (e.g. "Run N mechanical sweeps"). A count is a generator-coverage consumer that silently drifts whenever rows are added by any prior session.

**Suggested fix:** Add to the README drift check: when an edit changes the size of any enumerated set the README quotes a count of, recount from the authoritative source files and overwrite the literal — do not increment the displayed number. Grep the README for digit-bearing count phrases tied to the changed set.
