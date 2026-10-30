---
skill: wk-sitrep
date: 2026-10-30
type: correction
severity: high
verified-against-source: no
---

Render gate passed on a page whose three columns were nested inside each other; verify layout geometry, not containment.

**What happened:** The Stage 5 gate asserted three non-empty `.sitrep-col`, every item inside a column, and zero
`.st-item` without `.st-cb`. To satisfy the last clause, checkbox-less info lines were rewritten as raw text ending in
`<br>`. The page was announced ready, but the user saw one giant block: columns 2 and 3 were children of column 1.
`closest('.sitrep-col')` is true for nested columns, so the gate could not fail on this defect.

**Root cause:** (unverified — inferred from symptom) The gate checks DOM membership, never position. Raw text lines
between spans appear to make the markdown widget drop the first column's closing div; reverting those lines to
`st-item` spans restored the layout, but the parser mechanism was not read. Separately, the "zero `.st-item` without
`.st-cb`" clause conflicts with the long-standing convention of non-actionable info lines and sub-headings as
checkbox-less `st-item` spans.

**Suggested fix:** In Stage 5, assert each `.sitrep-col` is a direct child of `.sitrep-row` and the three have distinct,
increasing left edges, and take a screenshot before announcing. Scope the no-checkbox clause to actionable items (exempt
informational and sub-heading spans) and forbid raw text or `<br>` lines inside a column. Also state a rule for re-running
`start` on the same day: either regather or say the earlier gather was reused.
