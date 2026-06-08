---
class: principle
---

- **Rule:** Never put a widget object (`widget.html()`, `widget.new{}`,
  e.g. `sitrep.standupBox(...)`) inside a markdown table cell. Use inline
  backtick code spans for selectable in-cell content; emit copy-button
  widgets as a standalone line below the table.
- **Why:** A `${...}` expression returning a widget object serializes its
  Lua fields (`HTML`, `_ISWIDGET`) as a nested data table — SilverBullet
  has no inline-widget handler for table cells; widgets render only as a
  standalone line.
- **Where:** "render live.md as one 3-column table" HARD RULE (alongside
  the `⬜`/`✅`-not-`- [ ]` cell-rendering rule).
