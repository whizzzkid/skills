---
class: principle
---

- **Rule** — Assert each UI claim on its measured property, never on a screenshot or DOM text alone. "Same size/box
  as X" means identical rendered width and height: give the control set one shared fixed width, then measure
  `getBoundingClientRect()` on every variant in the browser and assert the values are equal before claiming it.
- **Why** — Copying box metrics (min-height, padding, radius, border, font) does not produce one size: with
  padding-plus-content sizing, width follows label length, so short and icon-plus-label variants render at different
  widths. A screenshot reviewed for color and layout does not show a few-pixel width difference.
- **Where** — Phase 3.6 (Frontend Live Preview). The existing persistence-claim check (network request counts or a
  window marker instead of DOM text) became one bullet with the size check, because both are cases where the visible
  output looks right while the claimed property is false.
