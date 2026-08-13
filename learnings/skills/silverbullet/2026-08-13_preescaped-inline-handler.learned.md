---
skill: wk-silverbullet
date: 2026-08-13
type: correction
severity: high
verified-against-source: yes
---

Validate rendered inline event handlers as executable DOM properties, not only as source strings.

**What happened:** A generated page pre-escaped a JavaScript `&&` operator inside an HTML attribute. The page renderer
escaped it again, leaving a literal entity string and causing the browser to discard the entire handler. After fixing
the handler, validation mocked the final clipboard write and reused a browser tab without proving the OS write or making
success and failure visible.

**Root cause:** Source-level markup validation checked for clipboard symbols and list hierarchy but did not assert that
the rendered button's `onclick` property was a function or exercise both clipboard branches.

**Suggested fix:** Require browser validation to assert the rendered handler is callable, exercise the real clipboard
promise from a browser gesture, force the rich-copy rejection path to prove the plain-text fallback, and expose visible
success or failure. Reload a fresh page after source changes. Write raw JavaScript operators in source HTML attributes;
let the renderer perform the required entity escaping.
