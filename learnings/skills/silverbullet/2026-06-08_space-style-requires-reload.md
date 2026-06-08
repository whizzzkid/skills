---
skill: wk-silverbullet
date: 2026-06-08
type: gap
severity: medium
---

`space-style` CSS changes require a browser page reload to take effect — never assume live update.

**What happened:** CSS classes added to the `space-style` block in the `#meta` page did not apply to the current page view after the file was written and pushed. The rendered DOM showed correct class names in HTML but `window.getComputedStyle()` returned browser defaults, not the new rules.

**Root cause:** SilverBullet loads `space-style` at editor initialization time, not continuously. Edits to the `#meta` style page are not hot-reloaded. The running instance continues using the CSS snapshot from the last full load.

**Suggested fix:** After modifying the `space-style` block in the `#meta` page, always reload the browser page before verifying CSS changes. When debugging CSS that seems correct in source but wrong in the rendered output, check for this stale-load issue first.
