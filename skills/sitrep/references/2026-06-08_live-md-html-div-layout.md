---
class: principle
---

- **Rule:** Render `live.md` as an HTML `<div>` flexbox 3-column layout with
  `<span data-done>` checkboxes — not a markdown table. Detect done/pending by
  the `data-done` attribute, not `✅`/`⬜` glyphs or `[x]`/`[ ]`.
- **Why:** Markdown table cells cannot hold SilverBullet's interactive task
  widgets, so the table format only ever produced read-only glyphs; the HTML
  div layout supports `<span onclick>` checkboxes that persist to file.
- **Where:** "render live.md as an HTML div 3-column layout" HARD RULE; Stage 4
  / Stage 4b write templates; `end` Stage 1/3/5 done-vs-pending detection.
- **Supersedes:** the earlier same-day 3-column-**table** HARD RULE and the
  `2026-06-06_widget-not-renderable-in-table-cells` reference (table format
  abandoned). Layout mechanics now delegate to `wk-silverbullet`.
