---
skill: wk-sitrep
date: 2026-06-06
type: correction
severity: high
---

`widget.html()` cannot render inside a markdown table cell — SilverBullet always shows the widget object as a data table.

**What happened:** Tried to embed a `sitrep.standupBox()` widget (styled pre + copy button) inside a col3 table cell using `${sitrep.standupBox("...")}`. Tried both: (a) mixed inline with `<br>` content in the cell, (b) as the sole content in a dedicated second row. Both times SilverBullet rendered the widget object's internal properties (HTML, _ISWIDGET) as a markdown data table instead of executing the widget.

**Root cause:** `widget.html()` and `widget.new{}` return a Lua table object with special SilverBullet fields. When a `${...}` expression inside a markdown table cell returns this object, SilverBullet's inline expression handler serializes the Lua table as a markdown table — it has no special-case logic to render widget objects inline within table cells. `widget.html()` only works as a **standalone line** expression outside tables.

**Suggested fix:** The standup snippet cannot have a copy-button widget in col3 of a markdown table. Best in-cell alternative: inline backtick code spans per line (monospace, selectable, in col3). For a true copy button, the options are:
- Move the standup below the table as a standalone `${sitrep.standupBox(...)}` expression (widget renders correctly as standalone, but is below the table).
- Use a non-table layout (e.g., `#col1`/`#col2`/`#col3` hashtag approach from community thread 3905 — but note: this only columnizes single tagged lines; transclusions still render full-width outside the flex item).
- Keep the inline code spans and document that the user can triple-click to select and copy.

**Convention going forward:** Generate standup in col3 as inline backtick code spans. If a copy widget is required, add it as a STANDALONE `${sitrep.standupBox(...)}` call on its own line, outside the table, clearly labeled — never inside a table cell.
