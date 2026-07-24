---
skill: wk-sitrep
date: 2026-07-24
type: correction
severity: medium
---

A blank line placed before/after a nested `<div class="st-copy-block">` inside a `sitrep-col` column terminated the parent column's HTML block early, ejecting the standup snippet as a separate full-width block below the 3-column row instead of inside its column.

**What happened:** When composing the standup copy-block section of `live.md`, blank lines were inserted around the `st-copy-block` div for readability (matching normal markdown style). The render-verification check only asserted `.sitrep-col` count === 3 and non-empty text — it passed even though the copy block had visually escaped its column, because the column div still contained other text. The user caught the broken layout from a screenshot; the automated check missed it.

**Root cause:** CommonMark type-6 HTML blocks end at the first blank line. A blank line anywhere inside an open `<div>` — not just around the outermost row/col divs — closes that div early. The existing render-verification JS (`sitrep-col length===3 && every non-empty`) only checks column count and non-emptiness, not that nested content stayed inside its column boundary.

**Suggested fix:** (1) When writing any nested `<div>` inside a `sitrep-col` (copy blocks, etc.), never leave a blank line before or after it — treat the entire column body as one contiguous run of lines. (2) Strengthen the render-verification snippet to also assert that known nested markers (e.g. `.st-copy-block`, `.st-standup`) are found *inside* a `.sitrep-col` ancestor, not just present on the page — e.g. `document.querySelectorAll('.sitrep-col .st-copy-block').length === document.querySelectorAll('.st-copy-block').length`. A screenshot check alone is not systematic enough to catch this every time.
