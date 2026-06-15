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
  version: '2026.06.15-200628'
  model:
    openai: gpt-4.1-mini
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

Read before writing any SilverBullet content.

### HTML blocks — no blank lines inside

- **HARD RULE:** Never put a blank line inside a `<div>` block.
- CommonMark type-6 HTML blocks end at the first blank line → a blank line inside a `<div>` terminates the block, ejects subsequent content as separate blocks, `<div>` renders empty.
- Replace blank-line separators inside columns with `<br>` or contiguous lines.
- Applies to ALL type-6 elements — `<div>`, `<span>`, `<section>`, etc.

### Input elements are disabled

- **HARD RULE:** Never use `<input>` (incl. `type="checkbox"`), `<button>`, or `<select>` inside an HTML widget.
- HTML widget renderer adds `disabled="disabled"` to all form elements → prevents hijacking editor cursor events. `onclick` on disabled `<input>` also silently stripped.
- Use `<span onclick="...">` + CSS `::before` for interactive checkboxes.
- Pattern: `<span class="st-cb" data-t="{id}" data-done="false" onclick="HANDLER"></span>`.

### onclick attribute constraints

Two characters break inline onclick attributes:

1. **`>` (greater-than)** — parser closes the opening tag at the first `>` even inside an attribute value → arrow functions (`=>`) break the handler silently.
2. **`"` (double-quote)** — terminates the attribute value → breaks the handler, corrupts surrounding markup.

Rules:
- Replace `=>` arrow functions with `function(){}`.
- Replace `"` string literals with `'` single quotes where possible.
- For runtime-required double-quotes, use `var q=String.fromCharCode(34)` and build strings from it.
- Prefer `.then()` chains over `async/await` → avoids `>`, keeps handlers short.

### No HTTP file API — use window.client

- **HARD RULE:** Never call `fetch()` to read/write SilverBullet page files.
- Service worker intercepts ALL fetch requests → returns the SPA HTML shell. `/_/page.md`, `/fs/page.md`, `/.fs/page.md`, `/api/page/name` all return 200 with `content-type: text/html`.
- Files live in IndexedDB; only safe programmatic access is `window.client` (Step 3).

### Markdown table cells — no interactive tasks

- Native `- [ ]` checkboxes do not render inside table cells — task widget decoration requires block-level context; inside a cell text renders literally as `- [ ]`.
- Use `⬜`/`✅` emoji glyphs for read-only status indicators in table cells.
- For interactive checkboxes in a multi-column layout, use HTML `<div>` columns (Step 2).
- Never embed `widget.html()` or `widget.new{}` inside a table cell → Lua table object serializes as a nested markdown data table instead of rendering. Widgets are standalone-line expressions only.

### Inline markdown inside HTML blocks

Rendered (inline): `**bold**` → `<strong>` ✅; `[text](url)` → link ✅; emojis ✅
NOT rendered (block-level): `- [ ]` → literal ✗; ATX headings `## H` → literal ✗; fenced code blocks → literal ✗

Write column content with inline markdown freely; substitute `<strong>`, `<a>`, etc. for any block construct.

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

## Step 2: HTML Column Layout

For interactive checkboxes or rich per-column formatting, use the HTML div
column layout instead of a markdown table.

### space-style block (in `#meta` page)

Add to the `space-style` block — scope layout classes under `.cm-content` to
avoid global conflicts; dark-mode rules under `html[data-theme="dark"]`:

```css
/* Full-width editor */
:root { --editor-width: 100%; }
.cm-content { max-width: 100% !important; }
.cm-scroller { padding: 0 !important; }

/* 3-column row */
.sitrep-row { display: flex; flex-direction: row; gap: 0.8rem; width: 100%; align-items: flex-start; }
.sitrep-col { flex: 1; min-width: 0; padding: 0.7rem 0.9rem; border-radius: 8px; }

/* Custom checkbox span */
.st-cb { cursor: pointer; user-select: none; display: inline; }
.st-cb[data-done="false"]:before { content: '☐'; font-size: 1.25em; margin-right: 4px; }
.st-cb[data-done="true"]:before { content: '☑'; font-size: 1.25em; margin-right: 4px; color: #39ff14; }

/* Checklist items */
.st-item { display: block; padding-left: 1.1em; line-height: 1.75; }
.st-item:has(.st-cb[data-done="true"]) { text-decoration: line-through; opacity: 0.55; }

/* Suppress extra <br> between checklist items only */
.st-item + br { display: none; }

/* Hide frontmatter */
.sb-frontmatter { display: none !important; }
```

**HARD RULE — `<br>` suppression scope:** Use `.st-item + br { display: none }`
not `.sitrep-col br { display: none }`. The column-scoped rule collapses meeting
lines and `<pre>` content; the adjacent-sibling rule targets only inter-item gaps.

**After editing `space-style`:** force a reload to apply changes — `location.reload()`
alone is insufficient (see Step 4).

### Page structure

Write column content with NO blank lines inside any `<div>`:

```markdown
<div class="sitrep-row">
<div class="sitrep-col">
**Section Header**
<span class="st-item"><span class="st-cb" data-t="t1" data-done="false" onclick="HANDLER"></span> Item text [link](url)</span>
<span class="st-item"><span class="st-cb" data-t="t2" data-done="false" onclick="HANDLER"></span> Another item</span>
</div>
<div class="sitrep-col">
**Section 2**
<span class="st-item"><span class="st-cb" data-t="t3" data-done="false" onclick="HANDLER"></span> Item</span>
</div>
<div class="sitrep-col">
**Section 3**
<span class="st-item">Plain text item</span>
</div>
</div>
```

Each `data-t` value must be unique across the page — it is the key used to
locate and update the item in the page source.

### onclick handler

Replace `PAGE_NAME` with the page name (no `.md`); replace `HANDLER` inline in each `<span>` attribute:

```
var d=this.dataset.done==='true',t=this.dataset.t,q=String.fromCharCode(34);this.dataset.done=String(!d);window.client.space.readPage('PAGE_NAME').then(function(pg){var c=pg.text,s='data-t='+q+t+q+' data-done='+q+(d?'true':'false')+q,n='data-t='+q+t+q+' data-done='+q+String(!d)+q;return window.client.space.writePage('PAGE_NAME',c.replace(s,n))})
```

Handler steps:
1. Reads `data-done` from the clicked span.
2. Flips visual state immediately (`this.dataset.done = String(!d)`).
3. Reads full page text via `window.client.space.readPage`.
4. Replaces the exact `data-t="X" data-done="Y"` pair in source.
5. Writes text back via `window.client.space.writePage`.

No `>` (arrow functions) or `"` inside attribute values — all substituted.

## Step 3: window.client API

All in-browser file operations must go through `window.client.space`:

| Operation | Call |
|-----------|------|
| Read a page | `window.client.space.readPage('page/name')` → `Promise<{text: string}>` |
| Write a page | `window.client.space.writePage('page/name', text)` → `Promise<void>` |
| Delete a page | `window.client.space.deletePage('page/name')` |
| Navigate | `window.client.navigate('page/name')` |
| Save current | `window.client.save()` |
| Fire event | `window.client.dispatchAppEvent(name, data)` |

- Page names never carry the `.md` extension.
- `writePage` handles IndexedDB persistence + server sync automatically.
- Always use `.then()` chains from onclick attributes — no `async/await` (avoids `>`).

## Step 4: CSS Changes Require Force Reload

**HARD RULE:** After any `space-style` edit, force a reload using the write-back
pattern — `location.reload()` alone uses a cached snapshot.

From browser console or Playwright:

```javascript
const pg = await window.client.space.readPage('EMPLOYER/sitrep-style');
await window.client.space.writePage('EMPLOYER/sitrep-style', pg.text);
location.reload(true);
```

Replace `EMPLOYER/sitrep-style` with the actual `#meta` page path. The
write-back invalidates cached CSS → SilverBullet re-processes the `space-style`
block on reload.

## Step 5: CSS Selector Reference

Key selectors for `space-style` rules:

| Target | Selector |
|--------|----------|
| Full-width page | `:root { --editor-width: 100% }` + `.cm-content { max-width: 100% !important }` |
| HTML widget content | `.sitrep-col { ... }` (or `.cm-content .sitrep-col` for scoped) |
| Table cells | `.cm-content table td { ... }` |
| Dark theme | `html[data-theme="dark"] .cm-content .sitrep-col { ... }` |
| Frontmatter | `.sb-frontmatter { display: none !important }` |
| Done-state items | `.st-item:has(.st-cb[data-done="true"]) { text-decoration: line-through; opacity: 0.55; }` |
| Inter-item br only | `.st-item + br { display: none; }` |

CSS `:has()` is fully supported — use it for parent-based state styling without
JavaScript.

## Step 6: Verify Changes Visually

**HARD RULE:** After any CSS or HTML change, verify in a browser — a file diff
does not prove the running instance renders correctly. Service worker, IndexedDB
cache, CodeMirror live preview, and HTML widget scoping all sit between file and
rendered output.

Run this loop (Playwright MCP, or browser console for steps 1/3/4):

1. **Force style sync** if `space-style` changed — Step 4 write-back.
2. **Screenshot** full page (`browser_take_screenshot`) — confirms layout (e.g., 3 columns render, not 1).
3. **Inspect the DOM** (`browser_evaluate`) — screenshot misses hidden state:

   ```javascript
   window.getComputedStyle(el).display  // did the CSS apply?
   el.getAttribute('onclick')           // did the handler survive sanitization?
   el.disabled                          // is the element unexpectedly disabled?
   ```

4. **Test interactivity** — `.click()` a checkbox span, re-read the page (`window.client.space.readPage`) to confirm the toggle persisted to file.

Key Playwright MCP tools: `browser_navigate`, `browser_take_screenshot`, `browser_evaluate`, `browser_click`.

## Common Mistakes

All known failure modes:

- **Blank line inside `<div>`** → column renders empty; content falls below layout.
- **`<input type="checkbox">`** → disabled by SilverBullet; handler silently stripped.
- **`=>` in onclick attribute** → handler truncated at `>`; function never called.
- **`"` inside `"..."` attribute** → attribute closes early; handler and subsequent attributes break.
- **`fetch()` for page reads** → service worker returns SPA shell (content-type: text/html).
- **`widget.html()` inside table cell** → Lua object serialized as nested data table.
- **`- [ ]` inside table cell** → renders as literal text; no task widget decoration.
- **`location.reload()` after style change** → stale CSS; use write-back + hard reload.
- **`.sitrep-col br { display: none }`** → collapses all text in column including meetings.
- **Non-unique `data-t` values** → checkbox toggle replaces the wrong item in source.
- **Shipping a CSS/HTML change without a browser screenshot** → file looks right, render is wrong (single column, collapsed lines, disabled handlers).
- **`SB_USER` unset on a `0.0.0.0` bind** → workspace exposed without auth.

## Quick Reference

| Problem | Fix |
|---------|-----|
| Column renders empty | Remove all blank lines inside `<div>` tags |
| Checkbox not clickable | Replace `<input>` with `<span onclick>` |
| Handler truncated | Remove `=>` (use `function(){}`); no `"` in attribute |
| File read returns HTML | Use `window.client.space.readPage()` not `fetch()` |
| CSS not applying | Write-back the style page + `location.reload(true)` |
| Widget shows raw props | Move widget expression outside table to standalone line |
| Task items as text in table | Use `⬜`/`✅` glyphs or switch to HTML div columns |

## Requirements

- SilverBullet 2.x running locally or in a container
- `$SITREP_REPO` pointing to the SilverBullet content repo (for `wk-sitrep` integration)
- Browser access for force-reload verification after CSS changes

---

## Post-Completion

Invoke `wk-learn` with this skill's short name as the argument
(e.g., `wk-learn silverbullet`).
