---
name: wk-silverbullet
description: >-
  Use when creating, editing, or debugging SilverBullet pages, widgets, and
  dashboards — covers HTML blocks, interactive checkboxes, space-style CSS,
  the window.client API, and the file read/write layer. Auto-invoked whenever
  the agent works with SilverBullet content.
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Skill
  - "mcp__*playwright*__browser_navigate"
  - "mcp__*playwright*__browser_take_screenshot"
  - "mcp__*playwright*__browser_evaluate"
  - "mcp__*playwright*__browser_click"
model: sonnet
effort: medium
model-invocable: true
user-invocable: true
license: MIT
group: tools
metadata:
  author: whizzzkid
  version: "2026.10.09-171327"
  model:
    openai: gpt-5.6-terra
    google: gemini-2.5-flash
    cursor: composer-2
---

# SilverBullet

Working guide for SilverBullet 2.x pages, widgets, interactive dashboards.
Runs in a browser: CodeMirror live-preview editor + service worker that
intercepts all fetches.

## When to Use

- Creating/editing SilverBullet pages, including `live.md` dashboards
- Writing `space-style` CSS or Space Lua in the `#meta` page
- Adding interactive elements (checkboxes, onclick handlers, links)
- Debugging rendering anomalies (missing content, CSS not applying, handlers not firing)
- Migrating markdown tables to HTML div layouts

## Local Setup (docker-compose)

Minimal no-auth, localhost-only deployment for a personal workspace:

```yaml
services:
  silverbullet:
    image: ghcr.io/silverbulletmd/silverbullet:2.8.1
    restart: unless-stopped
    environment:
      - SB_USER=
    volumes:
      - ./space:/space
    ports:
      - "127.0.0.1:7487:3000"
```

- `SB_USER=` (empty) disables auth — correct for local-only use.
- `SB_USER=user:password` enables HTTP Basic Auth — add only when asked.
- Bind to `127.0.0.1`, never `0.0.0.0`, without auth — an open port on a
  network-accessible address is a security risk.
- Pin the image tag (`2.8.1`), never `latest` — SilverBullet has breaking
  changes between minor versions.
- The host workspace directory maps to `/space` inside the container.

## Critical Constraints Reference

Read [references/rendering-rules.md](references/rendering-rules.md) before writing any SilverBullet content. Key HARD RULES:
- No blank lines inside `<div>` blocks (CommonMark type-6 terminates at blank line)
- No `<input>`/`<button>`/`<select>` (widget renderer disables all form elements)
- No `>`, `"`, or pre-escaped `&` in onclick attributes
- No `fetch()` for file I/O — use `window.client.space` only
- No `- [ ]` or `widget.html()` inside table cells

## Step 1: Determine Content Type

Classify what you're building:

| Need | Use |
|------|-----|
| Static multi-column content | Markdown table with `⬜`/`✅` glyphs |
| Interactive checkboxes in columns | HTML `<div class="sitrep-row">` layout |
| Styled widgets | `space-style` in `#meta` page |
| In-browser file read/write | `window.client.space.readPage/writePage` |
| Page navigation from onclick | `window.client.navigate('page-name')` |
| Persistent state toggle | `data-done` attribute + window.client writePage |

## Step 2: HTML Column Layout & window.client API

CSS patterns (space-style block, column layout, checkbox spans, onclick handler) and the full `window.client.space` API reference are in [references/client-api.md](references/client-api.md).

Key rules: scope layout classes under `.cm-content`; use `.st-item + br { display: none }` (never `.sitrep-col br`); each `data-t` value must be unique; use `.then()` chains (no async/await).

## Step 3: Verify Changes Visually

**HARD RULE:** After any CSS or HTML change, verify in a browser — a file diff does not prove the running instance renders correctly.

Force-reload pattern, CSS selector reference, and the full 6-step verification loop (screenshot → DOM inspect → containment assert → interactivity test) are in [references/rendering-rules.md](references/rendering-rules.md).

## Common Mistakes

All known failure modes:

- **Blank line inside `<div>`** → column renders empty; content falls below layout.
- **Blank line padding a nested `<div>`/`<pre>`** → child ejected full-width below the parent, which still renders its other content.
- **Verifying with a presence/count assertion only** → escaped nested content still counts as present; assert containment.
- **`<input type="checkbox">`** → disabled by SilverBullet; handler silently stripped.
- **`=>` in onclick attribute** → handler truncated at `>`; function never called.
- **`"` inside `"..."` attribute** → attribute closes early; handler and subsequent attributes break.
- **`fetch()` for page reads** → service worker returns SPA shell (content-type: text/html).
- **`widget.html()` inside table cell** → Lua object serialized as nested data table.
- **`- [ ]` inside table cell** → renders as literal text; no task widget decoration.
- **`location.reload()` after style change** → stale CSS; use write-back + hard reload.
- **`.sitrep-col br { display: none }`** → collapses all text in column including meetings.
- **Non-unique `data-t` values** → checkbox toggle replaces the wrong item in source.
- **Pre-escaped `&&` in onclick** → renderer double-encodes → handler text is literal entities; browser discards it. Write raw operators.
- **Validated handler as source string only** → `getAttribute('onclick')` returns text even when browser rejected the JS; assert `typeof el.onclick === 'function'`.
- **Validated on stale tab** → cached DOM masks a broken handler after source edit; reload fresh first.
- **Shipping a CSS/HTML change without a browser screenshot** → file looks right, render is wrong (single column, collapsed lines, disabled handlers).
- **`SB_USER` unset on a `0.0.0.0` bind** → workspace exposed without auth.

## Requirements

- SilverBullet 2.x running locally or in a container
- `$SITREP_REPO` pointing to the SilverBullet content repo (for `wk-sitrep` integration)
- Browser access for force-reload verification after CSS changes

---

## Post-Completion

Invoke `wk-learn silverbullet`.
