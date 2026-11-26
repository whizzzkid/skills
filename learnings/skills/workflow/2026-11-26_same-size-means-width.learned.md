---
skill: wk-workflow
date: 2026-11-26
type: correction
severity: medium
verified-against-source: n/a
---

"Same box as the neighbouring buttons" means identical rendered size, width included.

**What happened:** A design ask said to render a locked status box in "the same button box" as the action buttons in
adjacent rows. The agent copied the button's box metrics (min-height, padding, radius, border, font) and reported the
box as "same size", but every label was content-sized, so the three variants (two short verbs and an icon+label)
rendered at three different widths. The user caught it from a preview.

**Root cause:** Box metrics were treated as size. Padding-plus-content sizing makes width depend on label length, and
the live-preview check looked at screenshots for color and layout, never measuring each variant's bounding box.

**Suggested fix:** In Phase 3.6, when an ask says a control set should be the "same box/size/button", give the whole
set one shared fixed inline-size (centred content) and verify by measuring `getBoundingClientRect()` width and height of
every variant in the browser, asserting they are equal, before claiming it. Screenshots alone do not catch
few-pixel width drift.
