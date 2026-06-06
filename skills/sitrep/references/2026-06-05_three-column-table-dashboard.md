---
class: principle
date: 2026-06-05
---

- **Rule:** Render `live.md` as ONE 3-column markdown table styled by a
  `space-style` block on a stable `#meta` page; use ⬜/✅ glyphs (not
  `- [ ]`) and `<br>`-joined single-line cells.
- **Why:** SilverBullet 2.x renders via CodeMirror live preview (no
  reading mode); a styled table is the only layout that reliably yields a
  full-width, themed, multi-column dashboard.
- **Where:** "HARD RULE — render live.md as one 3-column table"; Stage 4
  (start) and Stage 5 (end) templates.

Failed alternatives (do not retry):

- Raw HTML `<div>` wrappers — SB blocks embedded HTML; divs render empty
  and markdown flows out as siblings.
- CSS `columns`/`grid` on `.cm-content` — CodeMirror virtualizes and
  absolutely-positions lines; layout shatters.
- `#col1`/`#col2`/`#col3` hashtag-flexbox trick — only columnizes single
  tagged lines; a transclusion on a tagged line renders as a separate
  full-width sibling; also breaks cursor nav.
- Lua `widget.html` reading a data page — fragile/over-engineered; SB
  auto-disables `<input type=checkbox>` in widget HTML, and chained string
  methods in Space Lua throw "attempt to index a userdata value" (split
  `s:gsub(a,b):gsub(c,d)` into separate statements).
- `SETTINGS.md` `customStyles:` YAML — ignored by SB 2.x; CSS loads only
  from indexed `space-style` fenced blocks.
