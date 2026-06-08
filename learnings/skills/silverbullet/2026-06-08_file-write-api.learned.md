---
skill: wk-silverbullet
date: 2026-06-08
type: surprise
severity: high
---

`fetch('/_/page.md')` returns the SPA HTML shell — use `window.client.space.readPage/writePage` to read and write files.

**What happened:** Attempts to read/write files via `fetch('/_/$EMPLOYER/live.md')` from inline onclick handlers returned a 200 status but with `content-type: text/html` — the SPA app shell, not the file content. All three guessed paths (`/_/`, `/fs/`, `/.fs/`) behaved identically.

**Root cause:** SilverBullet's service worker intercepts ALL fetch requests from the page and returns the cached SPA shell for navigation-like paths. There is no accessible HTTP REST API from within the browser context.

**Suggested fix:** Use SilverBullet's internal client API directly:
- `window.client.space.readPage('page-name')` → `{text: string}` (page name without `.md` extension)
- `window.client.space.writePage('page-name', newText)` → writes to IndexedDB + syncs to server

Both are async and return Promises. Use `.then()` chains in onclick attributes (not async/await to avoid `>` in attribute values). This API handles all sync, IndexedDB, and server persistence automatically.
