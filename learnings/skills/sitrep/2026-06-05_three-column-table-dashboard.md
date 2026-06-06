---
skill: wk-sitrep
date: 2026-06-05
type: pattern
severity: high
---

Render the live dashboard as a single 3-column markdown TABLE styled with
space-style — not transclusion, flexbox-on-lines, or Lua widgets.

**What happened:** Spent a long session trying multiple SilverBullet
multi-column techniques for the live page. Most fight CodeMirror or SB's
security model and fail. A single markdown table + space-style CSS is the
only approach that reliably yields a full-width, themed, multi-column
dashboard.

**Root cause:** SilverBullet 2.x renders the page through CodeMirror live
preview (no separate reading mode), which constrains what layouts are
possible. Approaches that fail:

- Raw HTML `<div>` wrappers around markdown — SB blocks embedded HTML;
  divs render empty and the markdown flows out as siblings.
- CSS `columns`/`grid` on `.cm-content` — shatters layout (CodeMirror
  virtualizes and absolutely-positions lines).
- The `#col1`/`#col2`/`#col3` hashtag-flexbox CSS trick — only columnizes
  single tagged *lines*; a page transclusion on a tagged line renders as a
  separate full-width sibling widget *outside* the flex item, so it never
  columnizes. Also breaks cursor navigation.
- A Lua `widget.html` parser/renderer reading a data page — works but
  fragile and over-engineered: SB auto-disables `<input type=checkbox>`
  inside widget HTML, and **chained string methods in Space Lua throw
  "attempt to index a userdata value"** (e.g. `s:gsub(a,b):gsub(c,d)` or
  `s:gsub(...):lower()` — split into separate statements).
- `SETTINGS.md` `customStyles:` YAML — ignored by SB 2.x; CSS loads only
  from ` ```space-style ``` ` fenced blocks indexed as space-style objects.

**Suggested fix:** Both `start` and `end` should generate `live.md` as:
frontmatter + `# Live — {DATE}` + ONE markdown table with 3 columns.

1. Header row `| 🗓 Context & Conversations | 📡 Action Feed | 📋 Standup & Notes |`,
   a separator row, then ONE data row of 3 cells. Markdown tables require
   single-line rows, so each cell's whole content sits on that one row line,
   joined with `<br>`.
2. Column mapping — col1: Calendar + Slack + Email; col2: ASAP +
   Auto-Actions + GitHub (PRs to review + your PRs) + Jira; col3: Standup
   Snippet + This Week + Notes + Backlog.
3. Inside cells use `**bold**` sub-headers, `<br>` breaks, and ⬜/✅ glyphs
   for task state — `- [ ]` checkboxes do NOT render inside table cells (show
   as literal text). Keep urgency markers 🔴🟡🟢🟠 inline.
4. CRITICAL: escape `#` as `\#` in all link text / repo refs
   (`[repo\#NNN: title](url)`). Unescaped `#` triggers SB's hashtag parser
   inside link text, breaking the link into a tag node — the raw URL then
   shows and overlaps the cell. With `\#` escaped, `[text](url)` collapses to
   clean clickable text.
5. Keep styling as STABLE INFRA in a separate `#meta` style page
   (`$EMPLOYER/sitrep-style.md`) — never regenerate it daily, only rewrite
   `live.md`. That page holds a ` ```space-style ``` ` block (full-width:
   `:root{--editor-width:100%}` + `.cm-content{max-width:100% !important}` +
   scroller padding; `table{width:100%;table-layout:fixed;border-spacing:0.6rem}`
   with `td/th{width:33.33%;vertical-align:top}`; neon dark scoped to
   `html[data-theme="dark"]`) plus a ` ```space-lua ``` ` block forcing dark
   as the boot default (neon CSS only applies in dark mode):
   `event.listen{ name="editor:init", run=function() editor.setUiOption("darkMode", true) end }`.
6. SilverBullet runs in Docker; space-style/space-lua need re-indexing after
   edits (a browser reload picks them up). When changing styling, open the
   page in a browser and screenshot to verify — do not assume CSS applied.
   Theme attribute is `html[data-theme="light"|"dark"]`; width is the
   `--editor-width` CSS var (default 800px).
