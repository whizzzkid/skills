---
skill: wk-silverbullet
date: 2026-06-08
type: pattern
severity: high
---

Use Playwright MCP to visually verify SilverBullet page changes — screenshots and DOM inspection catch rendering issues that file diffs cannot.

**What happened:** Multiple CSS and HTML changes were made to the SilverBullet dashboard. Without visual verification, several regressions were shipped: the 3-column layout appeared correct in the file but rendered as single-column; `<br>` suppression looked right in CSS but collapsed meeting lines; span checkboxes appeared interactive but were actually disabled in the DOM.

**Root cause:** SilverBullet's rendering is non-trivial — it involves a service worker, IndexedDB caching, CodeMirror live preview, Space Lua initialization, and HTML widget scoping. A change to a file on disk does not guarantee the running instance reflects that change. Only a browser screenshot can confirm what the user actually sees.

**Suggested fix:** After every SilverBullet CSS or HTML change, run this verification loop:

1. **Force style sync** (if `space-style` changed):
   ```javascript
   const pg = await window.client.space.readPage('$EMPLOYER/sitrep-style');
   await window.client.space.writePage('$EMPLOYER/sitrep-style', pg.text);
   location.reload(true);
   ```

2. **Take a screenshot** via Playwright MCP `browser_take_screenshot` — full page for layout checks.

3. **Inspect DOM** via `browser_evaluate` to verify computed styles, element counts, and attribute states — screenshot alone misses hidden bugs:
   ```javascript
   window.getComputedStyle(el).display  // CSS actually applied?
   el.getAttribute('onclick')           // handler survived sanitization?
   el.disabled                          // element unexpectedly disabled?
   ```

4. **Test interactivity** by calling `.click()` on elements via `browser_evaluate` and checking both DOM state and file state (`window.client.space.readPage`) to confirm persistence.

**Key Playwright MCP tools for SilverBullet debugging:**
- `browser_navigate` → load the page
- `browser_take_screenshot` → visual confirmation
- `browser_evaluate` → DOM inspection and API calls
- `browser_click` → test interactive elements
