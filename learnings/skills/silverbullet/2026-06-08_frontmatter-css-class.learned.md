---
skill: wk-silverbullet
date: 2026-06-08
type: pattern
severity: low
---

SilverBullet renders YAML frontmatter with `.sb-frontmatter` CSS class — hide it with `display: none !important` in `space-style`.

**What happened:** The YAML frontmatter block at the top of a page (date, employer, generated_with fields) was always visible in the page view as colored text with a "frontmatter" label in the top-right corner, even when the metadata was already displayed elsewhere in the content.

**Root cause:** SilverBullet renders the frontmatter as part of the live document view, wrapping it in elements with `.sb-frontmatter` and `.sb-frontmatter-marker` classes.

**Suggested fix:** To hide frontmatter from the rendered view (e.g., when displaying metadata elsewhere in content), add to the `space-style` block: `.sb-frontmatter { display: none !important; }`. The frontmatter data remains in the file and is still accessible to SilverBullet's query engine and templates.
