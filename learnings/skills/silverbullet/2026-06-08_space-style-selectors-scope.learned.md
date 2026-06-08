---
skill: wk-silverbullet
date: 2026-06-08
type: pattern
severity: medium
---

`space-style` CSS applies globally but HTML widget content is inside `.cm-content .sb-html-widget` — scope flexbox rules to avoid conflicts.

**What happened:** CSS rules targeting `.sitrep-row` without any parent selector worked correctly. Rules for dark theme needed to be scoped to `html[data-theme="dark"] .cm-content .sitrep-col` to avoid bleeding into other elements.

**Root cause:** SilverBullet's CodeMirror editor wraps all content in `.cm-content`. HTML blocks are wrapped in `.sb-html-widget` inside `.cm-line` inside `.cm-content`. Space-style rules are injected as global `<style>` tags.

**Key selectors for space-style:**
- Full-width page: `:root { --editor-width: 100%; }` + `.cm-content { max-width: 100% !important; }`
- Table cells: `.cm-content table td { ... }`
- HTML widget content: `.cm-content .sitrep-col { ... }` (or just `.sitrep-col` for simple rules)
- Dark theme scoping: `html[data-theme="dark"] .cm-content .sitrep-col { ... }`
- Frontmatter: `.sb-frontmatter { display: none !important; }`
- Theme detection attribute: `html[data-theme="dark" | "light"]`
