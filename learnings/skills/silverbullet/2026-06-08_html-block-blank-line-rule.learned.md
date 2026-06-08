---
skill: wk-silverbullet
date: 2026-06-08
type: correction
severity: high
---

CommonMark type-6 HTML blocks end at the first blank line — never put blank lines inside `<div>` columns.

**What happened:** Multi-column layout using `<div class="col">` with markdown content inside each column rendered as a single column. The `<div>` opening tag was in the DOM but had no children; all content appeared below the column structure.

**Root cause:** CommonMark spec rule: a type-6 HTML block (which includes `<div>`) starts at the opening tag and ends at the next blank line. Blank lines between div tags and content break the nesting — each blank-line-delimited chunk becomes a separate HTML widget or markdown block.

**Suggested fix:** Never use blank lines inside `<div>` column blocks. Write all content on contiguous lines (no blank lines). Content-separating blank lines must be replaced with `<br>` or structural HTML. The tradeoff: `- [ ]` markdown lists won't render as native SilverBullet tasks inside the block.
