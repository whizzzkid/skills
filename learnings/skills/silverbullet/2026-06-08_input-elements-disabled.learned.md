---
skill: wk-silverbullet
date: 2026-06-08
type: correction
severity: high
---

SilverBullet adds `disabled="disabled"` to ALL `<input>` elements inside HTML widgets — use `<span onclick>` instead.

**What happened:** `<input type="checkbox" onchange="...">` was placed inside an HTML block. In the DOM, the element appeared with `disabled="disabled"` attribute and the `onchange` handler was mangled and truncated. The checkboxes were completely non-interactive.

**Root cause:** SilverBullet's HTML widget renderer intentionally disables all form elements (`<input>`, `<button>`, etc.) to prevent them from capturing clicks that the editor needs for cursor positioning. This is by design to maintain the editor-first interaction model.

**Suggested fix:** Use `<span class="st-cb" onclick="...">` instead of `<input type="checkbox">`. Span elements are NOT disabled by SilverBullet. Use CSS `::before` pseudo-element with `content: '☐'` / `content: '☑'` and toggle a `data-done` attribute to simulate checkbox behavior visually and persistently.
