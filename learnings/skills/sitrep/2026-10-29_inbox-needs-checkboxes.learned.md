---
skill: wk-sitrep
date: 2026-10-29
type: correction
severity: high
verified-against-source: n/a
---

A newly added list section rendered its items as checkbox-less bullets, and sat at the bottom of its column.

**What happened:** On request for a list of everything waiting on the user, the section was built as plain nested spans with a bullet glyph and no checkbox, appended low in the column, and long per-line prose. The user had to ask twice for fixes (checkboxes, readability, placement).

**Root cause:** The rendering contract says every actionable item carries a checkbox; a "link list" was treated as presentation, not as items. A guessed shape (checkbox-less bullets whose parent carries state) was also written into the contract, compounding the error. No rule said where such a section sits or how long a line may be.

**Suggested fix:** Any list of things the user must act on is a list of checkbox items, one per link; checkbox-less spans are for non-actionable text only. Place action sections directly under the urgency section, one short line per item, and run a render check that counts items without a checkbox in action sections before announcing.
