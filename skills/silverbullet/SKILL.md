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
model: sonnet
effort: medium
model-invocable: true
user-invocable: true
license: MIT
group: tools
metadata:
  author: whizzzkid
  version: '2026.06.08-185717'
  model:
    openai: gpt-4.1-mini
    google: gemini-2.5-flash
    cursor: composer-2
---

# SilverBullet

Working guide for SilverBullet 2.x pages, widgets, and interactive dashboards.
SilverBullet runs in a modern browser with a CodeMirror live-preview editor and
a service worker that intercepts all fetches. This skill encodes every constraint
discovered during dashboard development so future work does not re-discover them.

## When to Use

- Creating or editing SilverBullet pages, including `live.md` dashboards
- Writing `space-style` CSS or Space Lua in the `#meta` page
- Adding interactive elements (checkboxes, onclick handlers, links)
- Debugging rendering anomalies (content missing, CSS not applying, handlers
  not firing)
- Migrating content from markdown tables to HTML div layouts

## Critical Constraints Reference

Read this section before writing any SilverBullet content.

### HTML blocks — no blank lines inside

**HARD RULE:** Never put a blank line inside a `<div>` block.

CommonMark type-6 HTML blocks start at the opening tag and end at the first
blank line. A blank line inside a `<div>` column terminates the HTML block and
ejects all subsequent content as separate blocks — the `<div>` renders empty.

- Replace blank-line separators inside columns with `<br>` or contiguous lines.
- This applies to ALL `<div>`, `<span>`, `<section>`, etc. — any type-6 element.

### Input elements are disabled

**HARD RULE:** Never use `<input type="checkbox">` or any `<input>`, `<button>`,
or `<select>` element inside an HTML widget.

SilverBullet's HTML widget renderer adds `disabled="disabled"` to all form
elements to prevent them from hijacking the editor's cursor events. `onclick`
attributes on disabled `<input>` elements are also silently stripped.

- Use `<span onclick="...">` with CSS `::before` for interactive checkboxes.
- Pattern: `<span class="st-cb" data-t="{id}" data-done="false" onclick="HANDLER"></span>`.

### onclick attribute constraints

Two characters break inline onclick attributes:

1. **`>` (greater-than)** — SilverBullet's HTML parser closes the opening tag
   at the first `>` even inside an attribute value. Arrow functions (`=>`) break
   the handler silently.
2. **`"` (double-quote)** — terminates the attribute value; breaks the handler
   and corrupts the surrounding markup.

**Rules:**
- Replace `=>` arrow functions with `function(){}`.
- Replace `"` string literals with `'` single quotes where possible.
- For double-quote characters required at runtime, use
  `var q=String.fromCharCode(34)` and build strings from that variable.
- Prefer `.then()` chains over `async/await` (avoids `>` and keeps handlers
  short).

### No HTTP file API — use window.client

**HARD RULE:** Never call `fetch()` to read or write SilverBullet page files.

SilverBullet's service worker intercepts ALL fetch requests from the page and
returns the SPA HTML shell. `/_/page.md`, `/fs/page.md`, `/.fs/page.md`,
`/api/page/name` — all return 200 with `content-type: text/html`.

Files live in IndexedDB; the only safe programmatic access is through the
`window.client` API (see Step 3).

### Markdown table cells — no interactive tasks

Native `- [ ]` task checkboxes do not render inside markdown table cells.
SilverBullet's task widget decoration requires block-level markdown context;
inside a cell the text renders literally as `- [ ]`.

- Use `⬜`/`✅` emoji glyphs for read-only status indicators in table cells.
- For interactive checkboxes in a multi-column layout, use HTML `<div>` columns
  (see Step 2).
- Never embed `widget.html()` or `widget.new{}` inside a table cell — the Lua
  table object serializes as a nested markdown data table instead of rendering.
  Widgets are standalone-line expressions only.

### Inline markdown inside HTML blocks

SilverBullet renders **inline markdown** inside HTML blocks:
- `**bold**` → `<strong>` ✅
- `[text](url)` → clickable link ✅
- Emojis ✅

But NOT block-level markdown:
- `- [ ]` task items → literal text ✗
- ATX headings (`## H`) → literal text ✗
- Fenced code blocks → literal text ✗

Write column content using inline markdown freely; substitute `<strong>`, `<a>`,
and similar HTML for any block construct you need.

## Step 1: Determine Content Type

Before writing content, classify what you're building:

| Need | Use |
|------|-----|
| Static multi-column content | Markdown table with `⬜`/`✅` glyphs |
| Interactive checkboxes in columns | HTML `<div class="sitrep-row">` layout |
| Styled widgets | `space-style` in `#meta` page |
| In-browser file read/write | `window.client.space.readPage/writePage` |
| Page navigation from onclick | `window.client.navigate('page-name')` |
| Persistent state toggle | `data-done` attribute + window.client writePage |

## Step 2: HTML Column Layout

When interactive checkboxes or rich per-column formatting are required, use the
HTML div column layout instead of a markdown table.

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

Replace `PAGE_NAME` with the SilverBullet page name (no `.md` extension).
Replace `HANDLER` inline in each `<span>` attribute:

```
var d=this.dataset.done==='true',t=this.dataset.t,q=String.fromCharCode(34);this.dataset.done=String(!d);window.client.space.readPage('PAGE_NAME').then(function(pg){var c=pg.text,s='data-t='+q+t+q+' data-done='+q+(d?'true':'false')+q,n='data-t='+q+t+q+' data-done='+q+String(!d)+q;return window.client.space.writePage('PAGE_NAME',c.replace(s,n))})
```

This handler:
1. Reads the `data-done` state from the clicked span.
2. Flips the visual state immediately (`this.dataset.done = String(!d)`).
3. Reads the full page text via `window.client.space.readPage`.
4. Replaces the exact `data-t="X" data-done="Y"` pair in the source.
5. Writes the updated text back via `window.client.space.writePage`.

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
- `writePage` handles IndexedDB persistence and server sync automatically.
- Always use `.then()` chains from onclick attributes — no `async/await` to
  avoid `>`.

## Step 4: CSS Changes Require Force Reload

**HARD RULE:** After any `space-style` edit, force a reload using the write-back
pattern — `location.reload()` alone uses a cached snapshot.

From a browser console or Playwright:

```javascript
const pg = await window.client.space.readPage('EMPLOYER/sitrep-style');
await window.client.space.writePage('EMPLOYER/sitrep-style', pg.text);
location.reload(true);
```

Replace `EMPLOYER/sitrep-style` with the actual `#meta` page path. The
write-back invalidates the cached CSS and triggers SilverBullet to re-process
the `space-style` block on reload.

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

## Common Mistakes

Distilled from field reports on all known failure modes:

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
