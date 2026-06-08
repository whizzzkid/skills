---
skill: wk-silverbullet
date: 2026-06-08
type: correction
severity: high
---

SilverBullet's service worker intercepts ALL fetch requests from the page and returns the SPA shell — no HTTP REST file API is accessible from the browser.

**What happened:** `fetch('/_/page.md')`, `fetch('/fs/page.md')`, `fetch('/.fs/page.md')`, and `fetch('/api/page/name')` all returned HTTP 200 with `content-type: text/html` — the SilverBullet SPA HTML. None returned the file content.

**Root cause:** SilverBullet 2.x uses a service worker that intercepts all navigation and API requests, serving the SPA shell for anything that looks like a page navigation. Even XHR/fetch calls are intercepted. Files are stored in IndexedDB (key format: `content\x00path/to/file.md`, value: `Uint8Array`), but writing directly to IndexedDB without going through the SilverBullet sync layer risks data loss on next sync.

**Suggested fix:** Never attempt HTTP-based file reads/writes from inline JavaScript. Use `window.client.space.readPage/writePage` which goes through the proper sync layer. If IndexedDB inspection is needed (read-only), open the `sb_files_{hash}` database and read the `data` store with key `content\x00{path}`.
