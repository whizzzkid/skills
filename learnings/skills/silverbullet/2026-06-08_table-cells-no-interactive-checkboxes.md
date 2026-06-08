---
skill: wk-silverbullet
date: 2026-06-08
type: correction
severity: high
---

Markdown table cells cannot contain interactive `- [ ]` task checkboxes — use HTML div columns or emoji glyphs instead.

**What happened:** A 3-column layout was built using a markdown table with `| col1 | col2 | col3 |` structure. `- [ ]` items placed inside cells rendered as literal text `- [ ]`, not as clickable SilverBullet task widgets. ⬜/✅ emoji glyphs worked visually as read-only indicators.

**Root cause:** SilverBullet's task checkbox widgets (`- [ ]`) are a CodeMirror decoration applied to markdown content. Inside table cells, the markdown parser treats `- [ ]` as inline text, not a block-level task list item. The decoration is never applied.

**Suggested fix:** For interactive checkboxes in a multi-column layout, use `<div class="sitrep-row"><div class="sitrep-col">` HTML divs with no blank lines inside (per the blank-line rule). Use `<span>` elements with `onclick` handlers as custom checkboxes. For a purely visual (non-interactive) checklist, ⬜/✅ glyphs in table cells work fine.
