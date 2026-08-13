# wk-silverbullet

Working guide for SilverBullet 2.x — interactive HTML dashboards, `space-style` CSS,
the `window.client` file API, and every rendering constraint discovered in production.

**Version:** `2026.08.13-191814`

## When It Activates

Auto-invoked whenever the agent works with SilverBullet content:

- Creating or editing `live.md` dashboards
- Writing `space-style` CSS in the `#meta` page
- Adding interactive checkboxes or onclick handlers to pages
- Debugging blank columns, broken handlers, or CSS not applying
- Migrating markdown table layouts to interactive HTML div columns

## Key Rules

| Rule | Detail |
|------|--------|
| No blank lines inside `<div>` | CommonMark type-6 rule — blank line ends the block, at any nesting depth |
| Verify containment, not presence | Scoped count of every nested marker must equal its global count |
| No `<input>` elements | SilverBullet disables all form elements in HTML widgets |
| No `>`, `"`, or pre-escaped `&` in onclick | Use `function(){}` syntax; write raw `&&`/`||`; `String.fromCharCode(34)` for quotes |
| No `fetch()` for page I/O | Service worker returns SPA shell; use `window.client.space.readPage/writePage` |
| No widgets in table cells | `widget.html()` serializes as a nested data table |
| Reload after space-style edits | Write-back the style page + `location.reload(true)` |

## Critical APIs

```javascript
// Read a page
window.client.space.readPage('page/name').then(function(pg) { var text = pg.text; })

// Write a page
window.client.space.writePage('page/name', newText)

// Navigate
window.client.navigate('page/name')
```

## 3-Column Layout Quick-Start

See `SKILL.md §Step 2` for the full working recipe including:

- `space-style` CSS block with flexbox layout + custom checkbox spans
- HTML `<div class="sitrep-row/sitrep-col">` structure (no blank lines inside)
- onclick handler template (no `=>`, no `"`, uses `window.client`)

## Integration

- Used by [wk-sitrep](../sitrep/README.md) for writing `live.md` dashboards
- Auto-invoked alongside [wk-sitrep](../sitrep/README.md) for any page content work
