# HTML/CSS Rendering Rules

## HTML Blocks — No Blank Lines Inside

- **HARD RULE:** Never put a blank line anywhere inside an open `<div>` block — nesting depth is irrelevant.
- CommonMark type-6 HTML blocks end at the first blank line → a blank line inside a `<div>` terminates the block, ejects subsequent content as separate blocks, `<div>` renders empty.
- **CRITICAL — a blank line before or after a NESTED element ends the OUTER block too.** Markdown-style padding around an inner `<div>`/`<pre>` ejects that child out of its parent: it renders full-width below the layout while the parent still renders its other content, so a parent-level "is it non-empty" check passes.
- Treat a container's entire body as one contiguous run of lines; replace blank-line separators with `<br>`.
- Applies to ALL type-6 elements — `<div>`, `<span>`, `<section>`, etc.

## Input Elements Are Disabled

- **HARD RULE:** Never use `<input>` (incl. `type="checkbox"`), `<button>`, or `<select>` inside an HTML widget.
- HTML widget renderer adds `disabled="disabled"` to all form elements → prevents hijacking editor cursor events. `onclick` on disabled `<input>` also silently stripped.
- Use `<span onclick="...">` + CSS `::before` for interactive checkboxes.
- Pattern: `<span class="st-cb" data-t="{id}" data-done="false" onclick="HANDLER"></span>`.

## onclick Attribute Constraints

Three characters break inline onclick attributes:

1. **`>` (greater-than)** — parser closes the opening tag at the first `>` even inside an attribute value → arrow functions (`=>`) break the handler silently.
2. **`"` (double-quote)** — terminates the attribute value → breaks the handler, corrupts surrounding markup.
3. **`&` (ampersand)** — pre-escaping `&&` to `&amp;&amp;` in source → renderer double-encodes to literal entity text → handler discarded.

Rules:
- Write raw JavaScript operators (`&&`, `||`, `!`) in source — never pre-escape HTML entities in onclick values; the renderer handles escaping.
- Replace `=>` arrow functions with `function(){}`.
- Replace `"` string literals with `'` single quotes where possible.
- For runtime-required double-quotes, use `var q=String.fromCharCode(34)` and build strings from it.
- Prefer `.then()` chains over `async/await` → avoids `>`, keeps handlers short.

## No HTTP File API — Use window.client

- **HARD RULE:** Never call `fetch()` to read/write SilverBullet page files.
- Service worker intercepts ALL fetch requests → returns the SPA HTML shell. `/_/page.md`, `/fs/page.md`, `/.fs/page.md`, `/api/page/name` all return 200 with `content-type: text/html`.
- Files live in IndexedDB; only safe programmatic access is `window.client`.

## Markdown Table Cells — No Interactive Tasks

- Native `- [ ]` checkboxes do not render inside table cells — task widget decoration requires block-level context; inside a cell text renders literally as `- [ ]`.
- Use `⬜`/`✅` emoji glyphs for read-only status indicators in table cells.
- For interactive checkboxes in a multi-column layout, use HTML `<div>` columns.
- Never embed `widget.html()` or `widget.new{}` inside a table cell → Lua table object serializes as a nested markdown data table instead of rendering. Widgets are standalone-line expressions only.

## Inline Markdown Inside HTML Blocks

Rendered (inline): `**bold**` → `<strong>` ✅; `[text](url)` → link ✅; emojis ✅
NOT rendered (block-level): `- [ ]` → literal ✗; ATX headings `## H` → literal ✗; fenced code blocks → literal ✗

Write column content with inline markdown freely; substitute `<strong>`, `<a>`, etc. for any block construct.

## CSS Changes Require Force Reload

**HARD RULE:** After any `space-style` edit, force a reload using the write-back pattern — `location.reload()` alone uses a cached snapshot.

From browser console or Playwright:

```javascript
const pg = await window.client.space.readPage('EMPLOYER/sitrep-style');
await window.client.space.writePage('EMPLOYER/sitrep-style', pg.text);
location.reload(true);
```

Replace `EMPLOYER/sitrep-style` with the actual `#meta` page path. The write-back invalidates cached CSS → SilverBullet re-processes the `space-style` block on reload.

## CSS Selector Reference

| Target | Selector |
|--------|----------|
| Full-width page | `:root { --editor-width: 100% }` + `.cm-content { max-width: 100% !important }` |
| HTML widget content | `.sitrep-col { ... }` (or `.cm-content .sitrep-col` for scoped) |
| Table cells | `.cm-content table td { ... }` |
| Dark theme | `html[data-theme="dark"] .cm-content .sitrep-col { ... }` |
| Frontmatter | `.sb-frontmatter { display: none !important }` |
| Done-state items | `.st-item:has(.st-cb[data-done="true"]) { text-decoration: line-through; opacity: 0.55; }` |
| Inter-item br only | `.st-item + br { display: none; }` |

CSS `:has()` is fully supported — use it for parent-based state styling without JavaScript.

## Verification Loop

**HARD RULE:** After any CSS or HTML change, verify in a browser — a file diff does not prove the running instance renders correctly.

Run this loop (Playwright MCP, or browser console for steps 1/3/4):

1. **Force style sync** if `space-style` changed — write-back pattern.
2. **Screenshot** full page (`browser_take_screenshot`) — confirms layout (e.g., 3 columns render, not 1).
3. **Inspect the DOM** (`browser_evaluate`) — screenshot misses hidden state:
   ```javascript
   window.getComputedStyle(el).display  // did the CSS apply?
   typeof el.onclick === 'function'     // did the handler survive as executable JS?
   el.disabled                          // is the element unexpectedly disabled?
   ```
4. **Assert containment, not presence** (`browser_evaluate`) — a count/non-empty assertion on the parents passes while a nested block has escaped its parent. For every nested marker class, its scoped count must equal its global count:
   ```javascript
   document.querySelectorAll('PARENT CHILD').length === document.querySelectorAll('CHILD').length
   ```
5. **Reload fresh** — after source changes, navigate to the page fresh (`browser_navigate`) before validating; cached DOM may mask a broken handler.
6. **Test interactivity** — `.click()` a checkbox span, re-read the page (`window.client.space.readPage`) to confirm the toggle persisted to file.
