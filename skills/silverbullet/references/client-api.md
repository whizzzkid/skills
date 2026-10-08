# window.client API Patterns

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

## HTML Column Layout

For interactive checkboxes or rich per-column formatting, use the HTML div column layout instead of a markdown table.

### space-style Block (in `#meta` page)

Add to the `space-style` block — scope layout classes under `.cm-content` to avoid global conflicts; dark-mode rules under `html[data-theme="dark"]`:

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

**HARD RULE — `<br>` suppression scope:** Use `.st-item + br { display: none }` not `.sitrep-col br { display: none }`. The column-scoped rule collapses meeting lines and `<pre>` content; the adjacent-sibling rule targets only inter-item gaps.

**After editing `space-style`:** force a reload to apply changes — `location.reload()` alone is insufficient.

### Page Structure

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

Each `data-t` value must be unique across the page — it is the key used to locate and update the item in the page source.

### onclick Handler

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
