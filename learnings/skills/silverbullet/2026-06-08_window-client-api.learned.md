---
skill: wk-silverbullet
date: 2026-06-08
type: surprise
severity: high
---

`window.client` exposes SilverBullet's full internal client API — accessible from inline onclick handlers.

**What happened:** After exhausting all HTTP-based file write approaches (all failed due to service worker interception), `window.client` was discovered as an enumerable global containing the live SilverBullet client instance.

**Root cause:** SilverBullet attaches its main client object to `window.client` during initialization. This is an implementation detail, not a documented API, but it is stable across SilverBullet 2.x.

**Key methods available:**
- `window.client.space.readPage(name)` → `Promise<{text: string}>` — reads a page by name (no `.md` extension)
- `window.client.space.writePage(name, text)` → `Promise<void>` — writes a page, handles IndexedDB + server sync
- `window.client.space.deletePage(name)` — deletes a page
- `window.client.navigate(page)` — navigates to a page
- `window.client.save()` — saves the currently open page
- `window.client.dispatchAppEvent(name, data)` — fires SilverBullet internal events

**Suggested fix:** Use `window.client.space.readPage`/`writePage` for any in-browser file manipulation from onclick handlers or Space Lua scripts. Always use `.then()` chains (not async/await) when calling from HTML attribute onclick handlers to avoid `>` parsing issues.
