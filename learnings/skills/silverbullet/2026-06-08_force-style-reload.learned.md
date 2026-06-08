---
skill: wk-silverbullet
date: 2026-06-08
type: pattern
severity: high
---

`space-style` CSS changes require explicit force-sync via `window.client.space.writePage` + `location.reload(true)` — `location.reload()` alone is insufficient.

**What happened:** After modifying `sitrep-style.md` on disk and committing, a `location.reload()` in Playwright appeared to apply the new CSS (it showed the correct state), but the user's browser still had the old cached CSS. The stale CSS (`sitrep-col br { display: none }`) was still active, collapsing meeting lines.

**Root cause:** SilverBullet caches `space-style` CSS at editor init. The service worker serves cached assets. A normal reload reuses the cached CSS snapshot. A force-sync via the write API invalidates the cache and re-triggers space-style processing.

**Suggested fix:** After any `space-style` change, run from Playwright (or browser console):
```javascript
const pg = await window.client.space.readPage('$EMPLOYER/sitrep-style');
await window.client.space.writePage('$EMPLOYER/sitrep-style', pg.text);
location.reload(true);
```
This forces SilverBullet to re-process the style page and re-inject the CSS. The `location.reload(true)` hard-clears the browser cache; without the write-back, even a hard reload may return the stale CSS.
